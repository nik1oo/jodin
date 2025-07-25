package build
import "core:fmt"
import "core:os"
import "core:os/os2"
import "core:c/libc"
import "core:path/filepath"


main:: proc() {
	command: cstring
	current_directory: = os.get_current_directory()

	// ADD TO PATH //

	// COMPILE INTERPRETER //
	interpreter_directory: = filepath.join({current_directory, "src/interpreter"})
	command = fmt.caprintf(`make -C "%s"`, interpreter_directory)
	// fmt.println(command)
	libc.system(command)

}

