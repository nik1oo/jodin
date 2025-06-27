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
import "poll"


KERNEL_SOURCE_PIPE_NAME:: `jodin_kernel_source`
KERNEL_STDOUT_PIPE_NAME:: `jodin_kernel_stdout`
KERNEL_IOPUB_PIPE_NAME::  `jodin_kernel_iopub`


// INITIALIZE THE COMMUNICATION PIPES AND WAIT FOR CLIENT TO CONNECT //
connect_to_ipy_kernel:: proc(session: ^Session) -> (err: Error) {
	// fmt.println("[ INTERPRETER ] Connecting to IPy Kernel..."); os.flush(os.stdout)
	fmt.eprintln("Creating kernel source pipe...")
	err = external_pipe.init_by_name(&session.kernel_source_pipe, KERNEL_SOURCE_PIPE_NAME, os.O_RDONLY)
	if err != NOERR do return error_handler(err, "Could not create kernel source pipe.")
	err = external_pipe.connect(&session.kernel_source_pipe)
	if err != NOERR do return error_handler(os.Error(os.General_Error.Broken_Pipe), "Could not connect to named pipe %s: %v.", session.kernel_source_pipe.path, windows.GetLastError())
	fmt.eprintln("Done.")

	fmt.eprintln("Creating kernel stdout pipe...")
	err = external_pipe.init_by_name(&session.kernel_stdout_pipe, KERNEL_STDOUT_PIPE_NAME, os.O_WRONLY)
	if err != NOERR do return error_handler(err, "Could not create kernel stdout pipe.")
	err = external_pipe.connect(&session.kernel_stdout_pipe)
	if err != NOERR do return error_handler(os.Error(os.General_Error.Broken_Pipe), "Could not connect to named pipe %s: %v.", session.kernel_stdout_pipe.path, windows.GetLastError())
	fmt.eprintln("Done.")

	fmt.eprintln("Creating kernel iopub pipe...")
	err = external_pipe.init_by_name(&session.kernel_iopub_pipe, KERNEL_IOPUB_PIPE_NAME, os.O_WRONLY)
	if err != NOERR do return error_handler(err, "Could not create kernel iopub pipe.")
	err = external_pipe.connect(&session.kernel_iopub_pipe)
	if err != NOERR do return error_handler(os.Error(os.General_Error.Broken_Pipe), "Could not connect to named pipe %s: %v.", session.kernel_iopub_pipe.path, windows.GetLastError())
	fmt.eprintln("Done.")

	fmt.eprintln("Pipes:", session.kernel_source_pipe.path, session.kernel_stdout_pipe.path, session.kernel_iopub_pipe.path)
	// fmt.println("[ INTERPRETER ] Done connecting to IPy Kernel..."); os.flush(os.stdout)
	return NOERR }


disconnect_from_ipy_kernel:: proc(session: ^Session) -> (err: Error) {
	// fmt.println("[ INTERPRETER ] Disconnecting from client..."); os.flush(os.stdout)
	external_pipe.destroy(&session.kernel_source_pipe)
	if err != NOERR do return error_handler(err, "Could not destroy pipe jodin_kernel_source")
	external_pipe.destroy(&session.kernel_stdout_pipe)
	if err != NOERR do return error_handler(err, "Could not destroy pipe jodin_kernel_stdout")
	external_pipe.destroy(&session.kernel_iopub_pipe)
	if err != NOERR do return error_handler(err, "Could not destroy pipe jodin_kernel_iopub")
	// fmt.println("[ INTERPRETER ] Client disconnected..."); os.flush(os.stdout)
	return NOERR }


receive_message:: proc(session: ^Session) -> (cell_id: string, message: string, err: Error) {
	when ODIN_OS == .Windows {
		n_read: u32
		buffer: = make([]u8, 65_536)
		assert(bool(windows.ReadFile(auto_cast session.kernel_source_pipe.handle, auto_cast &buffer[0], 65_536, &n_read, nil)))
		assert(n_read > 0)
		message = string(buffer[0:n_read]) }
	else when ODIN_OS == .Linux { }
	fmt.eprintln("read:", message)
	// if poll.timed_out(start_time, PIPE_TIMEOUT) do return "", "", error_handler(os.Error(os.General_Error.Timeout), "Pipe read timed out.")
	// fmt.println("[ INTERPRETER ] Message received from client."); os.flush(os.stdout)
	message = strings.trim(message, " ")
	parts, _: = strings.split_lines_n(message, 2) // TODO Unhandled
	return parts[0], parts[1], NOERR }

