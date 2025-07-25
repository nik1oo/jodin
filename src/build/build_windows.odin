package build
import "core:fmt"
import "core:strings"
import "core:os/os2"


// add_to_path:: proc(current_directory: string) {
// 	path: = os2.get_env("PATH", context.allocator)
	// echo %PATH%
	// if ! strings.contains(path, current_directory) {
	// 	sep: = []u8{os2.Path_List_Separator}
	// 	if path[len(path)-1] != ';' do path = strings.join({ path, current_directory }, sep=string(sep))
	// 	else do path = strings.concatenate({ path, current_directory })
	// 	assert(strings.contains(path, "jodin"))
	// 	err: = os2.set_env("PATH", path)
	// 	fmt.println(err) }


	// state, stdout, stderr, start_error: = os2.process_exec(
	// 	desc=os2.Process_Desc{
	// 		command={`setx`, `PATH`, strings.concatenate({`%PATH%;`, current_directory})} },
	// 	allocator=context.allocator)
	// if start_error != nil {
	// 	fmt.printfln("start_error: %v", start_error) } }

