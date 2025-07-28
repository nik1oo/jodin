package jodin
import "base:runtime"
import "core:reflect"
import "core:fmt"
import "core:dynlib"
import "core:strings"
import "core:os"
import "core:os/os2"
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
when ODIN_OS == .Linux {
	TEMP_DIRECTORY_MODE: u32 :   os.S_IRWXU | os.S_IRGRP | os.S_IXGRP }
when ODIN_OS == .Windows {
	TEMP_DIRECTORY_MODE: u32 :   0 }
JODIN_LOG_PREFIX::               ANSI_GREEN + "[Jodin] " + ANSI_RESET
INTERPRETER_LOG_PREFIX::         ANSI_GREEN + "[JodinInterpreter] " + ANSI_RESET
INTERPRETER_ERROR_PREFIX::       ANSI_RED + "[JodinInterpreter] " + ANSI_RESET


main:: proc() {
	// NOTE vent/Scripts on Windows, venv/bin on Linux. //
	load_config()
	notebooks_path: = config.notebooks_path
	subcommand: string = (len(os.args) == 1) ? "" : (os.args[1][0] == '-') ? "" : os.args[1]
	working_dir, _: = os2.join_path({os.get_current_directory(), `src`, `python_kernel`}, context.allocator)
	venv_dir: = get_venv_directory()
	if len(os.args) > 2 do for arg in os.args[2:] {
		if strings.starts_with(arg, `-notebook-dir`) {
			notebooks_path = strings.split(arg, "=")[1] } }
	if subcommand != "" {
		switch subcommand {
		case "help":
			fmt.println(HELP_STRING)
		case "version":
			fmt.println("Version", VERSION)
		case `venv`:
			activate_path, _: = os2.join_path({venv_dir, "Scripts", "activate"}, context.allocator)
			fmt.printfln(`source "%s"`, activate_path)
		case "jupyter-console":
			libc.system(`poetry --directory=./src/python_kernel run jupyter console  --kernel jodin`)
		case "jupyter-server":
			libc.system(`poetry --directory=./src/python_kernel run jupyter server  --kernel jodin`)
		case "jupyter-notebook":
			libc.system(fmt.caprintf(`poetry --directory=./src/python_kernel run jupyter notebook --notebook-dir=%s`, notebooks_path))
		case "server":
			context.allocator = reporting_allocator.wrap_allocator(
				wrapped_allocator=context.allocator,
				report_alloc_error=report_alloc_error,
				allocator_allocator=runtime.heap_allocator())
			fmt.println(
				INTERPRETER_LOG_PREFIX,
				"Jodin: ",
				"Version: ",
				VERSION,
				sep = "")
			session: ^Session = new(Session)
			start_session(
				session,
				error_handler)
			defer end_session(session)
			err: = connect_to_ipy_kernel(session)
			if err != NOERR {
				session.error_handler(
					err,
					"Could not connect to Jodin kernel.")
				return }
			counter: uint = 1
			for {
				defer { counter += 1 }
				session_output_to_console(session)
				response, _ := strings.builder_make_len_cap(
					0,
					CELL_STDERR_PIPE_BUFFER_SIZE + CELL_STDERR_PIPE_BUFFER_SIZE)
				frontend_cell_id, code_raw, _: = receive_message(session)
				session_output_to_frontend(session)
				cell_stdout, cell_stderr, cell_iopub: string
				cell: ^Cell
				if frontend_cell_id not_in session.cells do cell, err = compile_new_cell(
					session,
					frontend_cell_id,
					code_raw,
					counter)
				else do cell, err = recompile_cell(
					session,
					frontend_cell_id,
					code_raw)
				os.flush(os.stdout)
				if cell.loaded do cell_stdout, cell_stderr, cell_iopub, err = run_cell(cell)
				session_stdout, _: = internal_pipe.read(&session.stdout_pipe)
				session_stderr, _: = internal_pipe.read(&session.stderr_pipe)
				fmt.sbprint(
					&response,
					ANSI_RESET,
					session_stdout,
					cell_stdout,
					sep = "")
				fmt.sbprintln(
					&response,
					ANSI_RED,
					session_stderr,
					cell_stderr,
					ANSI_RESET,
					sep = "")
				err = external_pipe.write_string(
					&session.kernel_stdout_pipe,
					string_or_newline(strings.to_string(response)),
					external_pipe.DEFAULT_TIMEOUT,
					external_pipe.DEFAULT_DELAY)
				assert(err == NOERR)
				if len(cell_iopub) > 0 {
					external_pipe.write_bytes(
						&session.kernel_iopub_pipe,
						transmute([]u8)cell_iopub,
						external_pipe.DEFAULT_TIMEOUT,
						external_pipe.DEFAULT_DELAY)
					assert(err == NOERR) }
				err = external_pipe.write_bytes(
					&session.kernel_iopub_pipe,
					make_empty_message(),
					external_pipe.DEFAULT_TIMEOUT,
					external_pipe.DEFAULT_DELAY)
				assert(err == NOERR)
				if session.exit do break }
		case `shell`:
			fmt.println(
				INTERPRETER_LOG_PREFIX,
				"Jodin: ",
				"Version: ",
				VERSION,
				sep = "")
			session: ^Session = new(Session)
			start_session(
				session,
				error_handler)
			defer end_session(session)
			counter: uint = 1
			for {
				defer { counter += 1 }
				response, _: = strings.builder_make_len_cap(
					0,
					CELL_STDERR_PIPE_BUFFER_SIZE + CELL_STDERR_PIPE_BUFFER_SIZE)
				code_builder, _: = strings.builder_make_len_cap(
					0,
					10_000)
				fmt.printf(ANSI_BOLD_GREEN + "In [%d]: " + ANSI_RESET, counter)
				for {
					line: []u8 = make(
						[]u8,
						1_000)
					total_read,_: = os.read(
						os.stdin,
						line)
					if total_read == 0 do break
					line_trimmed: = strings.trim_right(
						string(line[0:total_read]),
						"\n\r")
					fmt.sbprint(
						&code_builder,
						line_trimmed)
					if len(line_trimmed) == 0 do break
					if line_trimmed[len(line_trimmed)-1] != '\\' do break }
				cell_stdout, cell_stderr, cell_iopub: string
				code_raw: = strings.to_string(code_builder)
				frontend_cell_id: = fmt.aprint(counter)
				assert(frontend_cell_id not_in session.cells)
				cell, err: = compile_new_cell(session,
					frontend_cell_id,
					code_raw,
					counter)
				if cell.loaded do cell_stdout, cell_stderr, cell_iopub, err = run_cell(cell)
				session_stdout, _: = internal_pipe.read(&session.stdout_pipe)
				session_stderr, _: = internal_pipe.read(&session.stderr_pipe)
				fmt.sbprint(&response, ANSI_RESET, session_stdout, cell_stdout, sep = "")
				fmt.sbprintln(&response, ANSI_RED, session_stderr, cell_stderr, ANSI_RESET, sep = "")
				fmt.println(strings.to_string(response))
				if session.exit do break }
		case:
			fmt.println(
				INTERPRETER_ERROR_PREFIX + "Invalid subcommand",
				os.args[1]) } }
	else {
		fmt.println(HELP_STRING) } }

