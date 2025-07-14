package internal_pipe
import "core:fmt"
import "core:os"
import "core:sys/windows"


init:: proc(pipe: ^Internal_Pipe, size: uint) -> (err: os.Error) {
	input_handle, output_handle: windows.HANDLE
	security_attributes:= windows.SECURITY_ATTRIBUTES{nLength = size_of(windows.SECURITY_ATTRIBUTES), bInheritHandle = true}
	ok: = windows.CreatePipe(&output_handle, &input_handle, &security_attributes, cast(u32)size)
	if !ok do err = os.get_last_error()
	pipe.input_handle, pipe.output_handle = cast(os.Handle)input_handle, cast(os.Handle)output_handle
	return err }

