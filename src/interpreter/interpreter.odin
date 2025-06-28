#+private
package jodin
import "base:runtime"
import "core:reflect"
import "core:fmt"
import "core:mem"
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
import "internal_pipe"
import "external_pipe"
import "poll"


Variable:: struct { name: string, type: string, value: string }
Procedure:: struct { name: string, type: string, value: string }


// INTERPRETER SESSION //
Session:: struct {
	// ID //
	name:                           string,

	// CELLS //
	cells:                          map[string]^Cell,

	// HANDLES BACKUP //
	os_stdout:                      os.Handle,
	os_stderr:                      os.Handle,

	// HANDLES REROUTES //
	stdout_pipe:                    internal_pipe.Internal_Pipe,
	stderr_pipe:                    internal_pipe.Internal_Pipe,

	// PIPES TO KERNEL //
	kernel_source_pipe:             external_pipe.External_Pipe,
	kernel_stdout_pipe:             external_pipe.External_Pipe,
	kernel_iopub_pipe:              external_pipe.External_Pipe,

	// DIRECTORY //
	session_temp_directory:         string,
	session_temp_directory_handle:  os.Handle,

	// SYMBOL-MAP //
	__symmap__:                     map[string]rawptr }


write_to_stdout_pipe:: proc(session: ^Session, message: string) -> (err: Error) {
	message: = message
	if message == "" do message = " "
	return external_pipe.write_string(&session.kernel_stdout_pipe, message, PIPE_TIMEOUT, PIPE_DELAY) }


write_to_message_pipe:: proc(session: ^Session, message: Message) -> (err: Error) {
	err = external_pipe.write_bytes(&session.kernel_iopub_pipe, message)
	if err != NOERR do return error_handler(err, "Could not write to message pipe.")
	return NOERR }


start_session:: proc(session: ^Session) -> (err: Error) {
	t: = time.now()
	session.name = fmt.aprintf("session_%s", time_string())
	session.os_stdout = os.stdout
	session.os_stderr = os.stderr
	err = internal_pipe.init(&session.stdout_pipe, CELL_STDOUT_PIPE_BUFFER_SIZE)
	if err != NOERR do return error_handler(err, "Could not create stdout pipe.")
	err = internal_pipe.init(&session.stderr_pipe, CELL_STDERR_PIPE_BUFFER_SIZE)
	if err != NOERR do return error_handler(err, "Could not create stderr pipe.")
	context.logger = log.create_console_logger()
	session.cells = make(map[string]^Cell)
	session.__symmap__ = make(map[string]rawptr)
	temp_directory: = get_temp_directory()
	if ! os.exists(temp_directory) do os.make_directory(temp_directory, os.O_RDWR)
	session.session_temp_directory = filepath.join({temp_directory, session.name})
	if ! os.exists(session.session_temp_directory) {
		err = os.Error(os.make_directory(session.session_temp_directory, os.O_RDWR))
		if err != os.Error(os.General_Error.None) do return error_handler(err, "Couldn't create temp folder %s.", session.session_temp_directory) }
	session.session_temp_directory_handle, err = os.open(session.session_temp_directory)
	if err != os.Error(os.General_Error.None) do return error_handler(err, "Couldn't open temp folder %s.", session.session_temp_directory_handle)
	return NOERR }


read_cell_output:: proc(cell: ^Cell) -> (out_string: string, err_string: string, err: Error) {
	out_string, err = internal_pipe.read(&cell.stdout_pipe)
	if err != NOERR do return "", "", error_handler(err, "Could not read stdout pipe.")
	err_string, err = internal_pipe.read(&cell.stderr_pipe)
	if err != NOERR do return "", "", error_handler(err, "Could not read stderr pipe.")
	return out_string, err_string, NOERR }


read_session_output:: proc(session: ^Session) -> (out_string: string, err_string: string, err: Error) {
	out_string, err = internal_pipe.read(&session.stdout_pipe)
	if err != NOERR do return "", "", error_handler(err, "Could not read stdout pipe.")
	err_string, err = internal_pipe.read(&session.stderr_pipe)
	if err != NOERR do return "", "", error_handler(err, "Could not read stderr pipe.")
	return out_string, err_string, NOERR }


read_cell_iopub:: proc(cell: ^Cell) -> (out_string: string, err: Error) {
	out_string, err = internal_pipe.read(&cell.iopub_pipe)
	if err != NOERR do return "", error_handler(err, "Could not read iopub pipe.")
	return out_string, NOERR }


end_session:: proc(session: ^Session) -> (err: Error) {
	disconnect_from_ipy_kernel(session)
	return NOERR }


write_dll:: proc(cell: ^Cell) -> (err: Error) {
	if os.exists(cell.source_filepath) do os.remove(cell.source_filepath)
	err = os.write_entire_file_or_err(cell.source_filepath, transmute([]u8)cell.code)
	if err != os.Error(os.General_Error.None) do return error_handler(err, "Could not write DLL to %s.", cell.source_filepath)
	return NOERR }


compile_dll:: proc(cell: ^Cell) -> (err: Error) {
	build_log_filepath: = filepath.join({ cell.session.session_temp_directory, "build_log.txt" })
	build_command: = fmt.caprintf(`%s build %s %s -file -build-mode:dll -out:%s -linker:lld > "%s" 2>&1`, cell.tags.odin_path, cell.source_filepath, cell.tags.build_args, cell.dll_filepath, build_log_filepath)
	status: = libc.system(build_command)
	if status == -1 do return error_handler(General_Error.Spawn_Error, "Could not execture odin build command.")
	if ! os.exists(cell.dll_filepath) {
		build_log, err: = os.read_entire_file_from_filename(build_log_filepath)
		return error_handler(General_Error.Compiler_Error, string(build_log)) }
	os.remove(build_log_filepath)
	return NOERR }


load_dll:: proc(cell: ^Cell) -> (err: Error) {
	if ! os.exists(cell.dll_filepath) do return error_handler(os.Error(os.General_Error.Not_Exist), "Could not find DLL.")
	cell.library, cell.loaded = dynlib.load_library(cell.dll_filepath, global_symbols = true)
	if ! cell.loaded do return error_handler(General_Error.DLL_Error, "Could not load DLL. %s", dynlib.last_error())
	ptr: rawptr; found: bool

	ptr, found = dynlib.symbol_address(cell.library, "__init__")
	if ! found do return error_handler(General_Error.DLL_Error, "Could not find symbol __init__.")
	cell.__init__ = auto_cast ptr

	ptr, found = dynlib.symbol_address(cell.library, "__main__")
	if ! found do return error_handler(General_Error.DLL_Error, "Could not find symbol __main__.")
	cell.__main__ = auto_cast ptr

	ptr, found = dynlib.symbol_address(cell.library, "__update_symmap__")
	if ! found do return error_handler(General_Error.DLL_Error, "Could not find symbol __update_symmap__.")
	cell.__update_symmap__ = auto_cast ptr

	ptr, found = dynlib.symbol_address(cell.library, "__apply_symmap__")
	if ! found do return error_handler(General_Error.DLL_Error, "Could not find symbol __apply_symmap__.")
	cell.__apply_symmap__ = auto_cast ptr

	for procedure in cell.global_procedures {
		ptr, found = dynlib.symbol_address(cell.library, procedure.name)
		if ! found do return error_handler(General_Error.DLL_Error, "Could not find symbol %s.", procedure.name)
		cell.session.__symmap__[procedure.name] = auto_cast ptr }
	return NOERR }


unload_dll:: proc(cell: ^Cell) -> (err: Error) {
	if cell.loaded do return error_handler(General_Error.Invalid_State, "Attempt to unload DLL that wasn't loaded.")
	if ! dynlib.unload_library(cell.library) do return error_handler(General_Error.DLL_Error, "Could not unload DLL.")
	return NOERR }


stderr_to_frontend:: proc(session: ^Session) -> (err: Error) {
	if session.stderr_pipe.input_handle == os.INVALID_HANDLE do return error_handler(os.Error(os.General_Error.Broken_Pipe), "The stderr pipe is not opened.")
	os.stderr = auto_cast session.stderr_pipe.input_handle
	return NOERR }
stdout_to_frontend:: proc(session: ^Session) -> (err: Error) {
	if session.stdout_pipe.input_handle == os.INVALID_HANDLE do return error_handler(os.Error(os.General_Error.Broken_Pipe), "The stdout pipe is not opened.")
	os.stdout = auto_cast session.stdout_pipe.input_handle
	return NOERR }
stderr_to_console:: proc(session: ^Session) -> (err: Error) {
	os.stderr = session.os_stderr
	return NOERR }
stdout_to_console:: proc(session: ^Session) -> (err: Error) {
	os.stdout = session.os_stdout
	return NOERR }


variable_is_pointer:: proc(variable: Variable) -> bool {
	return (len(variable.type) > 0 && variable.type[0] == '^') }

