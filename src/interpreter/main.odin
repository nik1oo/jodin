package jodin
import "base:runtime"
import "core:reflect"
import "core:fmt"
import "core:dynlib"
import "core:strings"
import "core:os"
import "core:mem"
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
import "ipynb"
import "reporting_allocator"


VERSION::                        "0.1.0-alpha"
DEFAULT_CELL_TIMEOUT::           20
PIPE_TIMEOUT::                   10 * time.Second
PIPE_DELAY::                     100 * time.Millisecond
STACK_SIZE::                     64 * mem.Megabyte
KERNEL_SOURCE_PIPE_BUFFER_SIZE:: 64 * mem.Kilobyte
KERNEL_STDOUT_PIPE_BUFFER_SIZE:: 16 * mem.Kilobyte
KERNEL_STDERR_PIPE_BUFFER_SIZE:: 16 * mem.Kilobyte
KERNEL_IOPUB_PIPE_BUFFER_SIZE::  16 * mem.Megabyte
CELL_STDOUT_PIPE_BUFFER_SIZE::   16 * mem.Kilobyte
CELL_STDERR_PIPE_BUFFER_SIZE::   16 * mem.Kilobyte
CELL_ARENA_SIZE::                32 * mem.Megabyte


// main:: proc() {
// 	data, ok: = os.read_entire_file_from_filename("../../examples/demo.ipynb")
// 	assert(ok)
// 	parser: = ipynb.make_parser(data)
// 	notebook: = ipynb.make_notebook()
// 	ipynb.parse_notebook(&parser, &notebook)
// }


main:: proc() {
	context.allocator = reporting_allocator.wrap_allocator(
		wrapped_allocator=context.allocator,
		report_alloc_error=report_alloc_error,
		allocator_allocator=runtime.heap_allocator())
	fmt.println(ANSI_GREEN, "[JodinInterpreter]", ANSI_RESET, " jodin: ", "Version: ", VERSION, sep = "")
	session: ^Session = new(Session)
	start_session(session, error_handler)
	defer end_session(session)
	err: = connect_to_ipy_kernel(session)
	if err != NOERR { session.error_handler(err, "Could not connect to jodin kernel."); return }
	counter: uint = 1
	for {
		defer { counter += 1 }
		session_output_to_console(session)
		response, _ := strings.builder_make_len_cap(0, CELL_STDERR_PIPE_BUFFER_SIZE + CELL_STDERR_PIPE_BUFFER_SIZE)
		frontend_cell_id, code_raw, _: = receive_message(session)
		session_output_to_frontend(session)
		cell_stdout, cell_stderr, cell_iopub: string
		if slice.contains([]string{"exit", "quit"}, code_raw) do break
		cell: ^Cell
		if frontend_cell_id not_in session.cells do cell, err = compile_new_cell(session, frontend_cell_id, code_raw, counter)
		else do cell, err = recompile_cell(session, frontend_cell_id, code_raw)
		os.flush(os.stdout)
		if cell.loaded do cell_stdout, cell_stderr, cell_iopub, err = run_cell(cell)
		session_stdout, _: = internal_pipe.read(&session.stdout_pipe)
		session_stderr, _: = internal_pipe.read(&session.stderr_pipe)
		fmt.sbprint(&response, ANSI_RESET, session_stdout, cell_stdout, sep = "")
		fmt.sbprintln(&response, ANSI_RED, session_stderr, cell_stderr, ANSI_RESET, sep = "")
		err = external_pipe.write_string(&session.kernel_stdout_pipe, string_or_newline(strings.to_string(response)), external_pipe.DEFAULT_TIMEOUT, external_pipe.DEFAULT_DELAY)
		assert(err == NOERR)
		if len(cell_iopub) > 0 {
			external_pipe.write_bytes(&session.kernel_iopub_pipe, transmute([]u8)cell_iopub, external_pipe.DEFAULT_TIMEOUT, external_pipe.DEFAULT_DELAY)
			assert(err == NOERR) }
		err = external_pipe.write_bytes(&session.kernel_iopub_pipe, make_empty_message(), external_pipe.DEFAULT_TIMEOUT, external_pipe.DEFAULT_DELAY)
		assert(err == NOERR) } }

