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
	name:                           string,
	cells:                          map[string]^Cell,
	os_stdout:                      os.Handle,
	os_stderr:                      os.Handle,
	stream_in:                      io.Stream,
	stream_out:                     io.Stream,
	stdout_pipe:                    internal_pipe.Internal_Pipe,
	stderr_pipe:                    internal_pipe.Internal_Pipe,
	kernel_source_pipe:             external_pipe.External_Pipe,
	kernel_stdout_pipe:             external_pipe.External_Pipe,
	kernel_iopub_pipe:              external_pipe.External_Pipe,
	session_temp_directory:         string,
	session_temp_directory_handle:  os.Handle,
	__symmap__:                     map[string]rawptr }


write_to_stdout_pipe:: proc(session: ^Session, message: string) -> (err: Error) {
	message: = message
	if message == "" do message = " "
	return external_pipe.write_string(&session.kernel_stdout_pipe, message, PIPE_TIMEOUT, PIPE_DELAY) }


write_to_message_pipe:: proc(session: ^Session, message: Message) -> (err: Error) {
	err = external_pipe.write_bytes(&session.kernel_iopub_pipe, message)
	if err != NOERR do return error_handler(err, "Could not write to message pipe.")
	return NOERR }


init_cell:: proc(cell: ^Cell, cell_id: string, code_raw: string, index: uint = 0) -> (err: Error) {
	session: = cell.session
	cell.id = strings.clone(cell_id)
	cell.name = fmt.aprintf("cell_%s_%d", time_string(), index)
	cell.package_filepath = filepath.join({session.session_temp_directory, fmt.aprintf("%s", cell.name)})
	cell.source_filepath = filepath.join({session.session_temp_directory, cell.name, fmt.aprintf("%s.odin", cell.name)})
	cell.dll_filepath = filepath.join({session.session_temp_directory, cell.name, fmt.aprintf("%s.dll", cell.name)})
	cell.code_raw = code_raw
	cell.loaded = false
	cell.cell_context = runtime.default_context()
	cell.cell_context.user_index = 1234
	mem.tracking_allocator_init(&cell.allocator, runtime.heap_allocator())
	cell.cell_context.allocator = mem.tracking_allocator(&cell.allocator)
	mem.scratch_allocator_init(&cell.temp_allocator, runtime.DEFAULT_TEMP_ALLOCATOR_BACKING_SIZE, cell.cell_context.allocator)
	cell.cell_context.temp_allocator = mem.scratch_allocator(&cell.temp_allocator)
	err = os.make_directory(cell.package_filepath)
	if err != os.Error(os.General_Error.None) do return error_handler(err, "Could not make directory %s.", cell.package_filepath)
	err = os.write_entire_file_or_err(cell.source_filepath, transmute([]u8)cell.code_raw)
	if err != os.Error(os.General_Error.None) do return error_handler(err, "Could not write to %s.", cell.source_filepath)
	err = internal_pipe.init(&cell.stdout_pipe, KERNEL_STDOUT_PIPE_BUFFER_SIZE)
	if err != NOERR do return error_handler(err, "Could not create stdout pipe.")
	err = internal_pipe.init(&cell.stderr_pipe, KERNEL_STDERR_PIPE_BUFFER_SIZE)
	if err != NOERR do return error_handler(err, "Could not create stderr pipe.")
	err = internal_pipe.init(&cell.iopub_pipe, KERNEL_IOPUB_PIPE_BUFFER_SIZE)
	if err != NOERR do return error_handler(err, "Could not create iopub pipe.")
	return NOERR }
reinit_cell:: proc(cell: ^Cell, code_raw: string) -> Error {
	cell.code_raw = code_raw
	cell.loaded = false
	clear_dynamic_array(&cell.package_directives)
	clear_dynamic_array(&cell.global_constants)
	clear_dynamic_array(&cell.global_variables)
	clear_dynamic_array(&cell.main_statements)
	cell.import_stmts = ""
	os.remove(cell.source_filepath)
	err: Error = os.write_entire_file_or_err(cell.source_filepath, transmute([]u8)cell.code_raw)
	if err != os.Error(os.General_Error.None) do return error_handler(err, "Could not write to %s.", cell.source_filepath)
	return NOERR }


destroy_cell:: proc(cell: ^Cell) {
	// TODO
}


start_session:: proc(session: ^Session) -> (err: Error) {
	t: = time.now()
	session.name = fmt.aprintf("session_%s", time_string())
	session.os_stdout = os.stdout
	session.os_stderr = os.stderr
	session.stream_in = os.stream_from_handle(os.stdin)
	session.stream_out = os.stream_from_handle(os.stdout)
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


cell_thread_proc:: proc(cell: ^Cell) {
	cell.__init__(cell, auto_cast cell.stdout_pipe.input_handle, auto_cast cell.stderr_pipe.input_handle, auto_cast cell.iopub_pipe.input_handle, &cell.session.__symmap__)
	cell.__apply_symmap__()
	cell.__main__()
	cell.__update_symmap__() }


run_cell_single_threaded:: proc(cell: ^Cell) -> (cell_stdout: string, cell_stderr: string, cell_iopub: string, err: Error) {
	cell_thread_proc(cell)
	cell_stdout, cell_stderr, _ = read_cell_output(cell)
	cell_iopub, _ = read_cell_iopub(cell)
	return cell_stdout, cell_stderr, cell_iopub, NOERR }


run_cell_multi_threaded:: proc(cell: ^Cell) -> (cell_stdout: string, cell_stderr: string, cell_iopub: string, err: Error) {
	cell_thread: = thread.create_and_start_with_poly_data(cell, cell_thread_proc, init_context = context, priority = .Normal, self_cleanup = false)
	if cell_thread == nil do return "", "", "", error_handler(General_Error.Spawn_Error, "Failed to spawn cell thread.")
	timer: time.Stopwatch
	time.stopwatch_start(&timer)
	for ! thread.is_done(cell_thread) {
		if int(time.duration_seconds(time.stopwatch_duration(timer))) >= cell.tags.timeout {
			thread.terminate(cell_thread, 0)
			error_handler(os.Error(os.General_Error.Timeout), "Cell timed out.")
			break } }
	cell_stdout, cell_stderr, _ = read_cell_output(cell)
	cell_iopub, _ = read_cell_iopub(cell)
	thread.destroy(cell_thread)
	return cell_stdout, cell_stderr, cell_iopub, NOERR }


run_cell:: proc(cell: ^Cell) -> (cell_stdout: string, cell_stderr: string, cell_iopub: string, err: Error) {
	return run_cell_multi_threaded(cell) }
	// return run_cell_single_threaded(cell) }


variable_is_pointer:: proc(variable: Variable) -> bool {
	return (len(variable.type) > 0 && variable.type[0] == '^') }


compile_cell:: proc(cell: ^Cell) -> (err: Error) {
	err = write_dll(cell); if err != NOERR do return error_handler(err, "Could not write DLL.")
	err = compile_dll(cell); if err != NOERR do return error_handler(err, "Could not compile DLL.")
	err = load_dll(cell); if err != NOERR do return error_handler(err, "Could not load DLL.")
	return NOERR }


compile_new_cell:: proc(session: ^Session, cell_id: string, code_raw: string, index: uint = 0) -> (cell: ^Cell, err: Error) {
	cell = new(Cell)
	cell.session = session
	err = init_cell(cell, cell_id, code_raw, index); if err != NOERR do return cell, error_handler(err, "Cell initialization failed.")
	err = preprocess_cell(cell); if err != NOERR do return cell, error_handler(err, "Cell preprocessing failed.")
	err = compile_cell(cell); if err != NOERR do return cell, error_handler(err, "Cell compilation failed.")
	// fmt.println(cell.code)
	session.cells[cell_id] = cell
	return cell, NOERR }


recompile_cell:: proc(session: ^Session, cell_id, code_raw: string) -> (cell: ^Cell, err: Error) {
	cell = session.cells[cell_id]
	if cell.loaded do unload_dll(cell)
	err = reinit_cell(cell, code_raw); if err != NOERR do return cell, error_handler(err, "Cell initialization failed.")
	err = preprocess_cell(cell); if err != NOERR do return cell, error_handler(err, "Cell preprocessing failed.")
	err = compile_cell(cell); if err != NOERR do return cell, error_handler(err, "Cell compilation failed.")
	// determine_dependers(cell)
	// recompile_dependers(cell)
	return cell, NOERR }

