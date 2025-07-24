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
import "core:sync"
import "internal_pipe"
import "external_pipe"
import "poll"


Cell:: struct {
	// MUTEX //
	mutex:                   sync.Mutex,

	// CELL CONTEXT //
	cell_context:            runtime.Context,
	cell_allocator:          mem.Arena,
	cell_temp_allocator:     mem.Arena,

	// PARENT SESSION //
	session:                 ^Session,

	// ID //
	frontend_cell_id:        string,
	name:                    string,

	// PATHS //
	package_filepath:        string,
	source_filepath:         string,
	dll_filepath:            string,

	// CODE //
	code_raw:                string,
	code:                    string,

	// PREPROCESSING INFORMATION //
	tags:                    Tags,
	imports_string:          string,
	global_constants_string: string,
	global_variables:        [dynamic]Variable,
	global_procedures:       [dynamic]Procedure,
	weak_dependers:          [dynamic]^Cell,
	strong_dependers:        [dynamic]^Cell,

	// DLL //
	library:                 dynlib.Library,
	compiled:                bool,
	loaded:                  bool,
	compilation_count:       int,

	// DLL CONTEXT //
	dll_context:             runtime.Context,
	dll_allocator:           mem.Tracking_Allocator,
	dll_temp_allocator:      mem.Scratch_Allocator,

	// SYMBOLS LINKED WITH THE DLL //
	__init__:                proc(cell: ^Cell, _stdout: os.Handle, _stderr: os.Handle, _iopub: os.Handle, __symmap__: ^map[string]rawptr),
	__main__:                proc(),
	__update_symmap__:       proc(),
	__apply_symmap__:        proc(),

	// PIPES FROM THE DLL TO THE INTERPRETER //
	stdout_pipe:             internal_pipe.Internal_Pipe,
	stderr_pipe:             internal_pipe.Internal_Pipe,
	iopub_pipe:              internal_pipe.Internal_Pipe }


init_cell:: proc(cell: ^Cell, session: ^Session, frontend_cell_id: string, code_raw: string, index: uint = 0) -> (err: Error) {
	// CELL CONTEXT //
	// TODO Execute context = cell.cell_context at the start of every top-level cell procedure. //
	// TEMP
	cell.cell_context = context
	// cell.cell_context = runtime.default_context()
	// mem.arena_init(&cell.cell_allocator, make([]u8, CELL_ARENA_SIZE))
	// cell.cell_context.allocator = mem.arena_allocator(&cell.cell_allocator)
	// cell.cell_context.temp_allocator = cell.cell_context.allocator
	context = cell.cell_context

	// PARENT SESSION //
	cell.session = session

	// ID //
	cell.frontend_cell_id = strings.clone(frontend_cell_id)
	cell.name = fmt.aprintf("cell_%s_%d", time_string(), index)

	// PATHS //
	cell.package_filepath = filepath.join({cell.session.session_temp_directory, fmt.aprintf("%s", cell.name)})
	cell.source_filepath = filepath.join({cell.session.session_temp_directory, cell.name, fmt.aprintf("%s.odin", cell.name)})
	cell.dll_filepath = filepath.join({cell.session.session_temp_directory, cell.name, fmt.aprintf("%s.dll", cell.name)})

	// DIRECTORIES //
	err = os.make_directory(cell.package_filepath, TEMP_DIRECTORY_MODE)
	if err != os.Error(os.General_Error.None) do return session.error_handler(err, "Could not make directory %s.", cell.package_filepath)

	// PIPES FROM THE DLL TO THE INTERPRETER //
	err = internal_pipe.init(&cell.stdout_pipe, KERNEL_STDOUT_PIPE_BUFFER_SIZE)
	if err != NOERR do return session.error_handler(err, "Could not create stdout pipe.")
	err = internal_pipe.init(&cell.stderr_pipe, KERNEL_STDERR_PIPE_BUFFER_SIZE)
	if err != NOERR do return session.error_handler(err, "Could not create stderr pipe.")
	err = internal_pipe.init(&cell.iopub_pipe, KERNEL_IOPUB_PIPE_BUFFER_SIZE)
	if err != NOERR do return session.error_handler(err, "Could not create iopub pipe.")
	return restart_cell(cell, code_raw) }


restart_cell:: proc(cell: ^Cell, code_raw: string) -> (err: Error) {
	session: = cell.session

	// CODE //
	cell.code_raw = code_raw
	cell.code = ""
	err = os.write_entire_file_or_err(cell.source_filepath, transmute([]u8)cell.code_raw)
	if err != os.Error(os.General_Error.None) do return session.error_handler(err, "Could not write to %s.", cell.source_filepath)

	// PREPROCESSING INFORMATION //
	cell.tags = { odin_path = "odin", build_args = "", timeout = DEFAULT_CELL_TIMEOUT }
	cell.imports_string = ""
	cell.global_constants_string = ""
	clear_dynamic_array(&cell.global_variables)
	clear_dynamic_array(&cell.global_procedures)
	clear_dynamic_array(&cell.weak_dependers)
	clear_dynamic_array(&cell.strong_dependers)

	// DLL //
	// DICK
	if cell.loaded do dynlib.unload_library(cell.library)
	cell.compiled = false
	cell.loaded = false
	cell.compilation_count += 1

	// DLL CONTEXT //
	if cell.compilation_count == 1 {
		// TEMP
		// cell.dll_context = runtime.default_context()
		cell.dll_context = context
		mem.tracking_allocator_init(&cell.dll_allocator, runtime.heap_allocator())
		cell.dll_context.allocator = mem.tracking_allocator(&cell.dll_allocator)
		mem.scratch_allocator_init(&cell.dll_temp_allocator, runtime.DEFAULT_TEMP_ALLOCATOR_BACKING_SIZE, cell.dll_context.allocator)
		cell.dll_context.temp_allocator = mem.scratch_allocator(&cell.dll_temp_allocator) }
	else {
		free_all(cell.dll_context.allocator)
		free_all(cell.dll_context.temp_allocator) }

	// SYMBOLS LINKED WITH THE DLL //
	cell.__init__ = nil
	cell.__main__ = nil
	cell.__update_symmap__ = nil
	cell.__apply_symmap__ = nil

	// DIRECTORIES //
	if os.exists(cell.source_filepath) do os.remove(cell.source_filepath)
	return NOERR }


destroy_cell:: proc(cell: ^Cell) {
	// DLL //
	dynlib.unload_library(cell.library)

	// DIRECTORIES //
	clear_directory(cell.package_filepath)

	// PIPES FROM THE DLL TO THE INTERPRETER //
	internal_pipe.destroy(&cell.stdout_pipe)
	internal_pipe.destroy(&cell.stderr_pipe)
	internal_pipe.destroy(&cell.iopub_pipe)

	free_all(cell.cell_context.allocator)
	free_all(cell.cell_context.temp_allocator) }


// Cell shared resources: //
// * cell
// * session.symmap


cell_thread_proc:: proc(cell: ^Cell) {
	cell.__init__(cell, auto_cast cell.stdout_pipe.input_handle, auto_cast cell.stderr_pipe.input_handle, auto_cast cell.iopub_pipe.input_handle, &cell.session.__symmap__)
	cell.__apply_symmap__()
	cell.__main__()
	cell.__update_symmap__() }


run_cell_single_threaded:: proc(cell: ^Cell) -> (cell_stdout: string, cell_stderr: string, cell_iopub: string, err: Error) {
	cell_thread_proc(cell)
	cell_stdout, _ = internal_pipe.read(&cell.stdout_pipe)
	cell_stderr, _ = internal_pipe.read(&cell.stderr_pipe)
	cell_iopub, _ = internal_pipe.read(&cell.iopub_pipe)
	return cell_stdout, cell_stderr, cell_iopub, NOERR }


run_cell_multi_threaded:: proc(cell: ^Cell) -> (cell_stdout: string, cell_stderr: string, cell_iopub: string, err: Error) {
	session: = cell.session
	// TODO Pass `cell.cell_context` to `init_context` argument, instead of setting it manually in the thread's `__init__` proc. //
	cell_thread: = thread.create_and_start_with_poly_data(cell, cell_thread_proc, init_context = context, priority = .Normal, self_cleanup = false)
	if cell_thread == nil do return "", "", "", session.error_handler(General_Error.Spawn_Error, "Failed to spawn cell thread.")
	if ! cell.tags.async {
		timer: time.Stopwatch
		time.stopwatch_start(&timer)
		for ! thread.is_done(cell_thread) {
			if int(time.duration_seconds(time.stopwatch_duration(timer))) >= cell.tags.timeout {
				thread.terminate(cell_thread, 0)
				session.error_handler(os.Error(os.General_Error.Timeout), "Cell timed out.")
				break } }
		cell_stdout, _ = internal_pipe.read(&cell.stdout_pipe)
		cell_stderr, _ = internal_pipe.read(&cell.stderr_pipe)
		cell_iopub, _ = internal_pipe.read(&cell.iopub_pipe)
		thread.destroy(cell_thread)
		return cell_stdout, cell_stderr, cell_iopub, NOERR }
	else {
		return "", "", "", NOERR } }


run_cell:: proc(cell: ^Cell) -> (cell_stdout: string, cell_stderr: string, cell_iopub: string, err: Error) {
	context = cell.cell_context
	return run_cell_multi_threaded(cell) }
	// return run_cell_single_threaded(cell) }


compile_cell:: proc(cell: ^Cell) -> (err: Error) {
	context = cell.cell_context
	session: = cell.session

	if session.print_source_on_error do defer {
		if err != NOERR {
			print_cell_content(cell)
			print_cell_code(cell) } }

	// WRITE DLL //
	if os.exists(cell.source_filepath) do os.remove(cell.source_filepath)
	err = os.write_entire_file_or_err(cell.source_filepath, transmute([]u8)cell.code)
	if err != os.Error(os.General_Error.None) do return session.error_handler(err, "Could not write DLL to %s.", cell.source_filepath)

	// COMPILE DLL //
	build_log_filepath: = filepath.join({ cell.session.session_temp_directory, "build_log.txt" })
	build_command: = fmt.caprintf(`%s build %s %s -file -build-mode:dll -out:%s -linker:lld > "%s" 2>&1`, cell.tags.odin_path, cell.source_filepath, cell.tags.build_args, cell.dll_filepath, build_log_filepath)
	status: = libc.system(build_command)
	if status == -1 do return session.error_handler(General_Error.Spawn_Error, "Could not execture odin build command.")
	if ! os.exists(cell.dll_filepath) {
		build_log, err: = os.read_entire_file_from_filename(build_log_filepath)
		// print_cell_content(cell)
		// print_cell_code(cell)
		return session.error_handler(General_Error.Compiler_Error, string(build_log)) }
	os.remove(build_log_filepath)

	// LOAD DLL //
	if ! os.exists(cell.dll_filepath) do return session.error_handler(os.Error(os.General_Error.Not_Exist), "Could not find DLL.")
	cell.library, cell.loaded = dynlib.load_library(cell.dll_filepath, global_symbols = true)
	if ! cell.loaded do return session.error_handler(General_Error.DLL_Error, "Could not load DLL. %s", dynlib.last_error())
	ptr: rawptr; found: bool
	ptr, found = dynlib.symbol_address(cell.library, "__init__")
	if ! found do return session.error_handler(General_Error.DLL_Error, "Could not find symbol __init__.")
	cell.__init__ = auto_cast ptr
	ptr, found = dynlib.symbol_address(cell.library, "__main__")
	if ! found do return session.error_handler(General_Error.DLL_Error, "Could not find symbol __main__.")
	cell.__main__ = auto_cast ptr
	ptr, found = dynlib.symbol_address(cell.library, "__update_symmap__")
	if ! found do return session.error_handler(General_Error.DLL_Error, "Could not find symbol __update_symmap__.")
	cell.__update_symmap__ = auto_cast ptr
	ptr, found = dynlib.symbol_address(cell.library, "__apply_symmap__")
	if ! found do return session.error_handler(General_Error.DLL_Error, "Could not find symbol __apply_symmap__.")
	cell.__apply_symmap__ = auto_cast ptr
	for procedure in cell.global_procedures {
		ptr, found = dynlib.symbol_address(cell.library, procedure.name)
		if ! found do return session.error_handler(General_Error.DLL_Error, "Could not find symbol %s.", procedure.name)
		cell.session.__symmap__[procedure.name] = auto_cast ptr }

	return NOERR }


compile_new_cell:: proc(session: ^Session, frontend_cell_id: string, code_raw: string, index: uint = 0) -> (cell: ^Cell, err: Error) {
	cell = new(Cell)
	err = init_cell(cell, session, frontend_cell_id, code_raw, index); if err != NOERR do return cell, err
	context = cell.cell_context
	err = preprocess_cell(cell); if err != NOERR do return cell, err
	err = compile_cell(cell); if err != NOERR do return cell, err
	// fmt.println(cell.code)
	session.cells[frontend_cell_id] = cell
	return cell, NOERR }


recompile_cell:: proc(session: ^Session, frontend_cell_id, code_raw: string) -> (cell: ^Cell, err: Error) {
	cell = session.cells[frontend_cell_id]
	context = cell.cell_context
	err = restart_cell(cell, code_raw); if err != NOERR do return cell, err
	err = preprocess_cell(cell); if err != NOERR do return cell, err
	err = compile_cell(cell); if err != NOERR do return cell, err
	// determine_dependers(cell)
	// recompile_dependers(cell)
	return cell, NOERR }


print_cell_content:: proc(cell: ^Cell) {
	fmt.eprintln(ANSI_BOLD_BLUE, "[CellContent]----------------------------------------", sep="")
	fmt.eprintln(cell.code_raw)
	fmt.eprintln("-----------------------------------------------------", ANSI_RESET, sep="") }


print_cell_code:: proc(cell: ^Cell) {
	fmt.eprintln(ANSI_BOLD_BLUE, "[CellSource]-----------------------------------------", sep="")
	fmt.eprintln(cell.code)
	fmt.eprintln("-----------------------------------------------------", ANSI_RESET, sep="") }

