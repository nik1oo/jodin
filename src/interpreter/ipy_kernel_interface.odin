#+private
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


connect_to_ipy_kernel:: proc(session: ^Session) -> (err: Error) {
	err = external_pipe.init_by_name(&session.kernel_source_pipe, KERNEL_SOURCE_PIPE_NAME, os.O_RDONLY, KERNEL_SOURCE_PIPE_BUFFER_SIZE)
	if err != NOERR do return error_handler(err, "Could not create kernel source pipe.")
	err = external_pipe.connect(&session.kernel_source_pipe)
	if err != NOERR do return error_handler(os.Error(os.General_Error.Broken_Pipe), "Could not connect to named pipe %s: %v.", session.kernel_source_pipe.path, windows.GetLastError())

	err = external_pipe.init_by_name(&session.kernel_stdout_pipe, KERNEL_STDOUT_PIPE_NAME, os.O_WRONLY, KERNEL_STDOUT_PIPE_BUFFER_SIZE)
	if err != NOERR do return error_handler(err, "Could not create kernel stdout pipe.")
	err = external_pipe.connect(&session.kernel_stdout_pipe)
	if err != NOERR do return error_handler(os.Error(os.General_Error.Broken_Pipe), "Could not connect to named pipe %s: %v.", session.kernel_stdout_pipe.path, windows.GetLastError())

	err = external_pipe.init_by_name(&session.kernel_iopub_pipe, KERNEL_IOPUB_PIPE_NAME, os.O_WRONLY, KERNEL_IOPUB_PIPE_BUFFER_SIZE)
	if err != NOERR do return error_handler(err, "Could not create kernel iopub pipe.")
	err = external_pipe.connect(&session.kernel_iopub_pipe)
	if err != NOERR do return error_handler(os.Error(os.General_Error.Broken_Pipe), "Could not connect to named pipe %s: %v.", session.kernel_iopub_pipe.path, windows.GetLastError())

	return NOERR }


disconnect_from_ipy_kernel:: proc(session: ^Session) -> (err: Error) {
	err = external_pipe.destroy(&session.kernel_source_pipe)
	if err != NOERR do return error_handler(err, "Could not destroy pipe jodin_kernel_source")
	err = external_pipe.destroy(&session.kernel_stdout_pipe)
	if err != NOERR do return error_handler(err, "Could not destroy pipe jodin_kernel_stdout")
	err = external_pipe.destroy(&session.kernel_iopub_pipe)
	if err != NOERR do return error_handler(err, "Could not destroy pipe jodin_kernel_iopub")
	return NOERR }


receive_message:: proc(session: ^Session) -> (frontend_cell_id: string, message: string, err: Error) {
	when ODIN_OS == .Windows {
		n_read: u32
		buffer: = make([]u8, KERNEL_SOURCE_PIPE_BUFFER_SIZE)
		assert(bool(windows.ReadFile(auto_cast session.kernel_source_pipe.handle, auto_cast &buffer[0], KERNEL_SOURCE_PIPE_BUFFER_SIZE, &n_read, nil)))
		assert(n_read > 0)
		message = string(buffer[0:n_read]) }
	else when ODIN_OS == .Linux { }
	message = strings.trim(message, " ")
	parts, _: = strings.split_lines_n(message, 2)
	return parts[0], parts[1], NOERR }

