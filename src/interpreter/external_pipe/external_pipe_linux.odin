package external_pipe
import "core:fmt"
import "core:os"
import "core:sys/linux"


pipe_path_is_valid:: proc(path: string) -> bool {
	return true }


make_path:: proc(name: string) -> string {
	return fmt.aprintf(`/tmp/pipe_%s`, name) }


init_by_path:: proc(pipe: ^External_Pipe, path: string, mode: int) -> (err: os.Error) {
	if ! ((mode == os.O_RDONLY) || (mode == os.O_WRONLY)) do return os.General_Error.Unsupported
	if ! pipe_path_is_valid(path) do return os.General_Error.Unsupported
	pipe.path = path
	err = linux.mknod(strings.clone_to_cstring(path), linux.S_IFFIFO, 0)
	if err != os.General_Error.None do return err
	pipe.handle, err = os.open(path, mode)
	return err }


destroy:: proc(pipe: ^External_Pipe) {
	os.close(pipe.handle) }