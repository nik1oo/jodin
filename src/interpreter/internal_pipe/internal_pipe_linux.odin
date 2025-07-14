package internal_pipe
import "core:fmt"
import "core:os"
import "core:sys/linux"


init:: proc(pipe: ^Internal_Pipe, size: uint) -> (err: os.Error) {
	handles: [2]linux.Fd
	err = linux.pipe2(&handles, {})
	// TODO Is it maybe the other way around? //
	pipe.input_handle, pipe.output_handle = cast(os.Handle)handles[0], cast(os.Handle)handles[1]
	return err }

