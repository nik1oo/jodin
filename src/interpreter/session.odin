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
import "core:sync"
import "internal_pipe"
import "external_pipe"
import "poll"


Variable:: struct { name: string, type: string, value: string }
Procedure:: struct { name: string, type: string, value: string }


// INTERPRETER SESSION //
Session:: struct {
	// MUTEX //
	data_mutex:                     sync.Mutex,

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

	// SYMBOL-MAP //
	__symmap__:                     map[string]rawptr }


start_session:: proc(session: ^Session) -> (err: Error) {
	session.name = fmt.aprintf("session_%s", time_string())
	session.os_stdout, session.os_stderr = os.stdout, os.stderr
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
	session_output_to_console(session)
	return NOERR }


end_session:: proc(session: ^Session) -> (err: Error) {
	// TODO Is there anything else I need to do here?
	return disconnect_from_ipy_kernel(session) }


session_output_to_frontend:: proc(session: ^Session) -> (err: Error) {
	err = os.Error(os.General_Error.Closed)
	if session.stdout_pipe.input_handle != os.INVALID_HANDLE do os.stdout = auto_cast session.stdout_pipe.input_handle
	else do return
	if session.stderr_pipe.input_handle != os.INVALID_HANDLE do os.stderr = auto_cast session.stderr_pipe.input_handle
	else do return
	return NOERR }
session_output_to_console:: proc(session: ^Session) -> (err: Error) {
	os.stderr = session.os_stderr
	os.stdout = session.os_stdout
	return NOERR }


variable_is_pointer:: proc(variable: Variable) -> bool {
	return (len(variable.type) > 0 && variable.type[0] == '^') }

