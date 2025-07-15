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
	fmt.eprintln("creating kernel source pipe")
	if err = external_pipe.init_by_name(
		&session.kernel_source_pipe,
		KERNEL_SOURCE_PIPE_NAME,
		os.O_RDONLY,
		KERNEL_SOURCE_PIPE_BUFFER_SIZE); err != NOERR do return err
	fmt.eprintln("connecting to kernel source pipe")
	if err = external_pipe.connect(&session.kernel_source_pipe); err != NOERR do return err
	fmt.eprintln("creating kernel stdout pipe")
	if err = external_pipe.init_by_name(
		&session.kernel_stdout_pipe,
		KERNEL_STDOUT_PIPE_NAME,
		os.O_WRONLY,
		KERNEL_STDOUT_PIPE_BUFFER_SIZE); err != NOERR do return err
	fmt.eprintln("connecting to kernel stdout pipe")
	if err = external_pipe.connect(&session.kernel_stdout_pipe); err != NOERR do return err
	fmt.eprintln("creating kernel iopub pipe")
	if err = external_pipe.init_by_name(
		&session.kernel_iopub_pipe,
		KERNEL_IOPUB_PIPE_NAME,
		os.O_WRONLY,
		KERNEL_IOPUB_PIPE_BUFFER_SIZE); err != NOERR do return err
	fmt.eprintln("connecting to kernel iopub pipe")
	if err = external_pipe.connect(&session.kernel_iopub_pipe); err != NOERR do return err
	return NOERR }


disconnect_from_ipy_kernel:: proc(session: ^Session) -> (err: Error) {
	if err = external_pipe.destroy(&session.kernel_source_pipe); err != NOERR do return err
	if err = external_pipe.destroy(&session.kernel_stdout_pipe); err != NOERR do return err
	if err = external_pipe.destroy(&session.kernel_iopub_pipe); err != NOERR do return err
	return NOERR }


receive_message:: proc(session: ^Session) -> (frontend_cell_id: string, message: string, err: Error) {
	// message, err = external_pipe.read_string(&session.kernel_source_pipe)
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

