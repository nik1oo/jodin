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


INTERPRETER_ERROR_PREFIX:: ANSI_RED + "[JodinInterpreter] " + ANSI_RESET


Error:: union {
	os.Error,
	runtime.Allocator_Error,
	General_Error,
	image.Error }
@(private) NOERR: Error = os.Error(os.General_Error.None)


@(private) nil_error_handler:: proc(err: Error, msg: string = "", args: ..any, loc: runtime.Source_Code_Location = #caller_location) -> Error {
	return err }


@(private) error_handler:: proc(err: Error, msg: string = "", args: ..any, loc: runtime.Source_Code_Location = #caller_location) -> Error {
	if err == NOERR do return err
	fmt.eprintf("%s%v: %s(%d:%d): ", INTERPRETER_ERROR_PREFIX, err, loc.file_path, loc.line, loc.column)
	fmt.eprintfln(msg, ..args)
	return err }


@(private) source_code_location_from_tokenizer_pos:: proc(pos: tokenizer.Pos) -> runtime.Source_Code_Location {
	return runtime.Source_Code_Location{ file_path = pos.file, line = auto_cast pos.line, column = auto_cast pos.column } }

