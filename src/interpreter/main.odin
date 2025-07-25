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
INTERPRETER_LOG_PREFIX::         ANSI_GREEN + "[JodinInterpreter] " + ANSI_RESET
INTERPRETER_ERROR_PREFIX::       ANSI_RED + "[JodinInterpreter] " + ANSI_RESET


main:: proc() {
	subcommand: string = (len(os.args) == 1) ? "" : (os.args[1][0] == '-') ? "" : os.args[1]
	working_dir, _: = os2.join_path({os.get_current_directory(), `src`, `python_kernel`}, context.allocator)
	notebook_dir: string = (ODIN_OS == .Windows) ? "/c" : "/"
	if len(os.args) > 2 do for arg in os.args[2:] {
		if strings.starts_with(arg, `-notebook-dir`) {
			notebook_dir = strings.split(arg, "=")[1] } }
	if subcommand != "" {
		switch subcommand {
		case "help":
			fmt.println(HELP_STRING)
		case "version":
			fmt.println("Version", VERSION)
		case "jupyter-console":
			libc.system(`poetry --directory=./src/python_kernel run jupyter console  --kernel jodin`)
			// state, stdout, stderr, err: = os2.process_exec(
			// 	desc=os2.Process_Desc{
			// 		command={`poetry`, `env`, `info`, `-p`}, working_dir=working_dir },
			// 	allocator=context.allocator)
			// venv_path: = string(stdout)
			// jupyter_console, _: = os2.join_path({ strings.trim_right(string(venv_path), "\n\r"), "Scripts", "jupyter-console.exe" }, context.allocator)
			// sep: []u8 = {os2.Path_Separator}
			// path_list: = strings.split(jupyter_console, string(sep))
			// fmt.println(path_list)
			// jupyter_console, _ = strings.join(path_list[2:], string(sep))
			// fmt.println(jupyter_console)
			// command: []string = {fmt.aprintf(`"%s"`, jupyter_console), `--kernel jodin`}
			// fmt.println(strings.join(command, sep=" "))
			// state, stdout, stderr, err = os2.process_exec(
			// 	{command=command, working_dir=working_dir},
			// 	allocator=context.allocator)
			// state, stdout, stderr, err = os2.process_exec(
			// 	{command={`poetry`, `run`, `jupyter`, `console`}, working_dir=working_dir},
			// 	allocator=context.allocator)
			// fmt.println(string(stdout), string(stderr))
		case "jupyter-notebook":
			// fmt.println(os2.stdout)
			libc.system(fmt.caprintf(`poetry --directory=./src/python_kernel run jupyter notebook --notebook-dir=%s`, notebook_dir))
			// process, err: = os2.process_start(
			// 	{command={`poetry`, `run`, `jupyter`, `notebook`}, working_dir=working_dir, stdout=os2.stdout})
			// for {
			// 	process_state, wait_err: = os2.process_wait(process, 1_000_000)
			// 	p: [100_000]u8
			// 	n, err: = io.read(os2.stdout.stream, p[:])
			// 	fmt.println(p[0:n])
			// 	os2.flush(os2.stdout)
			// 	if process_state.exited do break }
			// fmt.println(process, err)
			// state, stdout, stderr, err: = os2.process_exec(
			// 	{command={`poetry`, `run`, `jupyter`, `notebook`}, working_dir=working_dir},
			// 	allocator=context.allocator)
			// fmt.println(string(stdout), string(stderr))
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
		case:
			fmt.println(
				INTERPRETER_ERROR_PREFIX + "Invalid subcommand",
				os.args[1]) } }
	else {
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
			if session.exit do break } } }

