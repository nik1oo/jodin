package external_pipe
import "core:fmt"
import "core:os"
import "core:sys/linux"
import "core:strings"
import "core:path/filepath"


// I am starting to work on this. //


pipe_path_is_valid:: proc(path: string) -> bool {
	return true }


make_path:: proc(name: string) -> string {
	return filepath.join({os.get_current_directory(), ".temp", fmt.aprintf(`pipe_%s`, name)}) }


init_by_path:: proc(pipe: ^External_Pipe, path: string, mode: int, size: uint) -> (err: os.Error) {
	fmt.eprintln("creating pipe at path", path)
	if ! ((mode == os.O_RDONLY) || (mode == os.O_WRONLY)) do return os.General_Error.Unsupported
	if ! pipe_path_is_valid(path) do return os.General_Error.Invalid_Path
	pipe.path = path
	if ! os.exists(path) {
		fmt.eprintln("pipe not exists")
		if err = linux.mknod(strings.clone_to_cstring(path), {.IFIFO, .IRUSR, .IWUSR, .IXUSR}, 0); err != os.General_Error.None do return err
		fmt.eprintln("pipe created") }
	else {
		fmt.eprintln("pipe exists") }
	if pipe.handle, err = os.open(path, mode); err != os.General_Error.None do return err
	fmt.eprintln("pipe opened")
	return os.General_Error.None }


connect:: proc(pipe: ^External_Pipe) -> (err: os.Error) {
	if pipe.handle != os.INVALID_HANDLE do return os.General_Error.Not_Exist
	return os.General_Error.None }


destroy:: proc(pipe: ^External_Pipe) -> (err: os.Error) {
	return os.close(pipe.handle) }

