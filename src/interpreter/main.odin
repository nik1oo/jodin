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
import "external_pipe"


VERSION:: "0.1.0-alpha"
DEFAULT_CELL_TIMEOUT:: 10
JODIN:: "JOdin: "
JODIN_KERNEL:: "JOdin Kernel: "
PIPE_TIMEOUT:: 10 * time.Second
PIPE_DELAY:: 100 * time.Millisecond
#assert((ODIN_OS == .Windows) || (ODIN_OS == .Linux))
main:: proc() {
	err: Error
	fmt.println(JODIN, "Version: ", VERSION, sep = "")
	session: ^Session = new(Session)
	start_session(session)
	defer end_session(session)
	connect_to_ipy_kernel(session)
	// stderr_to_frontend(session)
	counter: uint = 1
	for {
		defer { counter += 1 }
		response, _ := strings.builder_make_len_cap(0, 100_000)
		fmt.sbprint(&response, ANSI_RED)
		cell_id, code_raw, _: = receive_message(session)
		cell_stdout, cell_stderr, cell_iopub: string
		if slice.contains([]string{"exit", "quit"}, code_raw) do break
		cell: ^Cell
		if cell_id not_in session.cells do cell, err = compile_new_cell(session, cell_id, code_raw, counter)
		else do cell, err = recompile_cell(session, cell_id, code_raw)
		// if err != NOERR do error_handler(&response, err, "Could not compile cell.")
		os.flush(os.stdout) // TODO Does this do anything? //
		if cell.loaded do cell_stdout, cell_stderr, cell_iopub, err = run_cell(cell)
		// if err != NOERR do error_handler(&response, err, "Could not run cell.")
		session_stdout, session_stderr, _: = read_session_output(session)
		fmt.sbprint(&response, ANSI_RESET, /*session_stdout,*/ cell_stdout, sep = "")
		fmt.sbprintln(&response, ANSI_RED, /*session_stderr,*/ cell_stderr, ANSI_RESET, sep = "")
		// time.sleep(5 * time.Second)
		err = external_pipe.write_string(&session.kernel_stdout_pipe, string_or_newline(strings.to_string(response)), external_pipe.DEFAULT_TIMEOUT, external_pipe.DEFAULT_DELAY)
		assert(err == NOERR)
		if len(cell_iopub) > 0 {
			// time.sleep(5 * time.Second)
			external_pipe.write_bytes(&session.kernel_iopub_pipe, transmute([]u8)cell_iopub, external_pipe.DEFAULT_TIMEOUT, external_pipe.DEFAULT_DELAY)
			assert(err == NOERR) }
		// time.sleep(5 * time.Second)
		err = external_pipe.write_bytes(&session.kernel_iopub_pipe, make_empty_message(), external_pipe.DEFAULT_TIMEOUT, external_pipe.DEFAULT_DELAY)
		assert(err == NOERR) } }