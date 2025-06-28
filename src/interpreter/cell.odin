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


Cell:: struct {
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
	cell.cell_context = runtime.default_context()
	mem.arena_init(&cell.cell_allocator, make([]u8, CELL_ARENA_SIZE))
	cell.cell_context.allocator = mem.arena_allocator(&cell.cell_allocator)
	cell.cell_context.temp_allocator = cell.cell_context.allocator
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
	err = os.make_directory(cell.package_filepath)
	if err != os.Error(os.General_Error.None) do return error_handler(err, "Could not make directory %s.", cell.package_filepath)

	// PIPES FROM THE DLL TO THE INTERPRETER //
	err = internal_pipe.init(&cell.stdout_pipe, KERNEL_STDOUT_PIPE_BUFFER_SIZE)
	if err != NOERR do return error_handler(err, "Could not create stdout pipe.")
	err = internal_pipe.init(&cell.stderr_pipe, KERNEL_STDERR_PIPE_BUFFER_SIZE)
	if err != NOERR do return error_handler(err, "Could not create stderr pipe.")
	err = internal_pipe.init(&cell.iopub_pipe, KERNEL_IOPUB_PIPE_BUFFER_SIZE)
	if err != NOERR do return error_handler(err, "Could not create iopub pipe.")
	return restart_cell(cell, code_raw) }


restart_cell:: proc(cell: ^Cell, code_raw: string) -> (err: Error) {
	// CODE //
	cell.code_raw = code_raw
	cell.code = ""
	err = os.write_entire_file_or_err(cell.source_filepath, transmute([]u8)cell.code_raw)
	if err != os.Error(os.General_Error.None) do return error_handler(err, "Could not write to %s.", cell.source_filepath)

	// PREPROCESSING INFORMATION //
	cell.tags = { odin_path = "odin", build_args = "", timeout = DEFAULT_CELL_TIMEOUT }
	cell.imports_string = ""
	cell.global_constants_string = ""
	clear_dynamic_array(&cell.global_variables)
	clear_dynamic_array(&cell.global_procedures)
	clear_dynamic_array(&cell.weak_dependers)
	clear_dynamic_array(&cell.strong_dependers)

	// DLL //
	dynlib.unload_library(cell.library)
	cell.compiled = false
	cell.loaded = false
	cell.compilation_count += 1

	// DLL CONTEXT //
	if cell.compilation_count == 1 {
		cell.dll_context = runtime.default_context()
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

