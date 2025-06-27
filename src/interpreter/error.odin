#+private
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


Error:: union {
	os.Error,
	General_Error }
NOERR: Error = os.Error(os.General_Error.None)


error_handler:: proc { error_handler_from_source_code_location, error_handler_from_source_code_location_sb, error_handler_from_tokenizer_pos }
error_handler_from_source_code_location_sb:: proc(sb: ^strings.Builder, err: Error, msg: string = "", args: ..any, loc: runtime.Source_Code_Location = #caller_location) -> Error {
	if err == NOERR do return err
	fmt.sbprintf(sb, "%v: %s(%d:%d): ", err, loc.file_path, loc.line, loc.column)
	fmt.sbprintfln(sb, msg, ..args)
	return err }
error_handler_from_source_code_location:: proc(err: Error, msg: string = "", args: ..any, loc: runtime.Source_Code_Location = #caller_location) -> Error {
	if err == NOERR do return err
	fmt.eprintf("%v: %s(%d:%d): ", err, loc.file_path, loc.line, loc.column)
	fmt.eprintfln(msg, ..args)
	return err }
error_handler_from_tokenizer_pos:: proc(err: Error, loc: tokenizer.Pos, msg: string, args: ..any) -> Error {
	if err == NOERR do return err
	return error_handler_from_source_code_location(err, msg, ..args, loc = source_code_location_from_tokenizer_pos(loc)) }


assert_handler:: proc { assert_handler_from_source_code_location, assert_handler_from_tokenizer_pos }
assert_handler_from_source_code_location:: proc(condition: bool, err: Error, msg: string = "", args: ..any, loc: runtime.Source_Code_Location = #caller_location) -> Error {
	if condition do return NOERR
	else do return error_handler_from_source_code_location(err, msg, ..args, loc = loc) }
assert_handler_from_tokenizer_pos:: proc(condition: bool, err: Error, loc: tokenizer.Pos, msg: string, args: ..any) -> Error {
	if condition do return NOERR
	else do return error_handler_from_tokenizer_pos(err, loc, msg, ..args) }


source_code_location_from_tokenizer_pos:: proc(pos: tokenizer.Pos) -> runtime.Source_Code_Location {
	return runtime.Source_Code_Location{ file_path = pos.file, line = auto_cast pos.line, column = auto_cast pos.column } }

