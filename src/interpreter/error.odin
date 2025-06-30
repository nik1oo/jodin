package jodin
import "base:runtime"
import "core:reflect"
import "core:fmt"
import "core:dynlib"
import "core:strings"
import "core:os"
import "core:c/libc"
import "core:odin/parser"
import "core:odin/tokenizer"
import "core:odin/ast"
import "core:path/filepath"
import "core:log"
import "core:io"
import "core:slice"
import "core:time"
import "core:sys/windows"
import "core:sys/posix"
import "core:unicode/utf16"
import "core:bytes"
import "core:thread"
import "core:image"


General_Error:: enum {
	Data_Empty,
	Invalid_Format,
	Invalid_Argument,
	Invalid_State,
	Spawn_Error,
	Preprocessor_Error,
	OS_Error,
	Runtime_Error,
	Compiler_Error,
	DLL_Error }


// Erros come form:
//  * python kernel, printed to the stdout stream of the kernel process.
//  * jodin interpreter, printed to os.stdout. [ ok ]
//  * compiler, printed to compiler log file [ ok ]
//  * cell, printed to the cell's stdout pipe. [ ok ]
//  * odin runtime error handler, printed directly to stderr, redirected to os.stderr.

INTERPRETER_ERROR_PREFIX:: ANSI_RED + "[JodinInterpreter]" + ANSI_RESET


Error:: union {
	os.Error,
	runtime.Allocator_Error,
	General_Error,
	image.Error }
@(private) NOERR: Error = os.Error(os.General_Error.None)


@(private) error_handler:: proc { error_handler_from_source_code_location, error_handler_from_source_code_location_sb, error_handler_from_tokenizer_pos }
@(private) error_handler_from_source_code_location_sb:: proc(sb: ^strings.Builder, err: Error, msg: string = "", args: ..any, loc: runtime.Source_Code_Location = #caller_location) -> Error {
	if err == NOERR do return err
	fmt.sbprintf(sb, "%s %v: %s(%d:%d): ", INTERPRETER_ERROR_PREFIX, err, loc.file_path, loc.line, loc.column)
	fmt.sbprintfln(sb, msg, ..args)
	return err }
@(private) error_handler_from_source_code_location:: proc(err: Error, msg: string = "", args: ..any, loc: runtime.Source_Code_Location = #caller_location) -> Error {
	if err == NOERR do return err
	fmt.eprintf("%s %v: %s(%d:%d): ", INTERPRETER_ERROR_PREFIX, err, loc.file_path, loc.line, loc.column)
	fmt.eprintfln(msg, ..args)
	return err }
@(private) error_handler_from_tokenizer_pos:: proc(err: Error, loc: tokenizer.Pos, msg: string, args: ..any) -> Error {
	if err == NOERR do return err
	return error_handler_from_source_code_location(err, msg, ..args, loc = source_code_location_from_tokenizer_pos(loc)) }


@(private) assert_handler:: proc { assert_handler_from_source_code_location, assert_handler_from_tokenizer_pos }
@(private) assert_handler_from_source_code_location:: proc(condition: bool, err: Error, msg: string = "", args: ..any, loc: runtime.Source_Code_Location = #caller_location) -> Error {
	if condition do return NOERR
	else do return error_handler_from_source_code_location(err, msg, ..args, loc = loc) }
@(private) assert_handler_from_tokenizer_pos:: proc(condition: bool, err: Error, loc: tokenizer.Pos, msg: string, args: ..any) -> Error {
	if condition do return NOERR
	else do return error_handler_from_tokenizer_pos(err, loc, msg, ..args) }


@(private) source_code_location_from_tokenizer_pos:: proc(pos: tokenizer.Pos) -> runtime.Source_Code_Location {
	return runtime.Source_Code_Location{ file_path = pos.file, line = auto_cast pos.line, column = auto_cast pos.column } }


@(private) copy_stderr:: proc(dest: os.Handle) {
	stderr_handle := os.get_std_handle(uint(windows.STD_ERROR_HANDLE))
	data, _: = os.read_entire_file_from_handle_or_err(stderr_handle)
	fmt.eprintln("read", len(data), "bytes from stderr.")
	os.write(dest, data) }

