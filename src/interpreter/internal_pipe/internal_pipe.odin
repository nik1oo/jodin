package internal_pipe
import "core:fmt"
import "core:os"
#assert((ODIN_OS == .Windows) || (ODIN_OS == .Linux))


Internal_Pipe:: struct {
	input_handle:  os.Handle,
	output_handle: os.Handle }


destroy:: proc(pipe: ^Internal_Pipe) {
	os.close(pipe.input_handle)
	os.close(pipe.output_handle) }


read:: proc(pipe: ^Internal_Pipe) -> (result: string, err: os.Error) {
	data: []u8; data, err = os.read_entire_file_from_handle_or_err(pipe.output_handle)
	return string(data), err }

