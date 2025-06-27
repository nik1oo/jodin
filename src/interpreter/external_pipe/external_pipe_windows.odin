package external_pipe
import "core:fmt"
import "core:os"
import "core:unicode/utf16"
import "core:sys/windows"


pipe_path_is_valid:: proc(path: string) -> bool {
	return path[0:9] == `\\.\pipe\` }


make_path:: proc(name: string) -> string {
	return fmt.aprintf(`\\.\pipe\%s`, name) }


init_by_path:: proc(pipe: ^External_Pipe, path: string, mode: int, size: uint) -> (err: os.Error) {
	if ! ((mode == os.O_RDONLY) || (mode == os.O_WRONLY)) do return os.General_Error.Unsupported
	if ! pipe_path_is_valid(path) do return os.General_Error.Unsupported
	pipe.path = path
	path_u16: = make([]u16, len(path) + 1)
	n_encoded: = utf16.encode_string(path_u16, path)
	if n_encoded != len(path) do return os.General_Error.Invalid_Path
	handle: = windows.CreateFileW(auto_cast &path_u16[0], (mode == os.O_RDONLY) ? windows.GENERIC_READ : windows.GENERIC_WRITE, 0, nil, windows.OPEN_EXISTING, 0, nil)
	if handle != windows.INVALID_HANDLE_VALUE do windows.CloseHandle(auto_cast handle)
	pipe.handle = auto_cast windows.CreateNamedPipeW(auto_cast &path_u16[0], (mode == os.O_RDONLY) ? windows.PIPE_ACCESS_INBOUND : windows.PIPE_ACCESS_OUTBOUND, windows.PIPE_TYPE_MESSAGE | windows.PIPE_READMODE_MESSAGE | windows.PIPE_WAIT, 1, cast(u32)size, cast(u32)size, 0, nil)
	if cast(windows.HANDLE)pipe.handle == windows.INVALID_HANDLE_VALUE do return os.General_Error.Invalid_File
	return err }


connect:: proc(pipe: ^External_Pipe) -> (err: os.Error) {
	assert(cast(windows.HANDLE)pipe.handle != windows.INVALID_HANDLE_VALUE)
	ok: = bool(windows.ConnectNamedPipe(auto_cast pipe.handle, nil))
	return os.General_Error.None }


destroy:: proc(pipe: ^External_Pipe) -> (err: os.Error) {
	windows.DisconnectNamedPipe(auto_cast pipe.handle)
	return os.close(pipe.handle) }

