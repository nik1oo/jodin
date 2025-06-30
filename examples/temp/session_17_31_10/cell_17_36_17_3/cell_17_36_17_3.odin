
package cell_17_36_17_3

import "shared:jodin"
import "core:io"
import "core:os"

import "core:fmt"
import "vendor:glfw"
import gl "vendor:OpenGL"
import "core:thread"
import "core:sync"

@(export) __cell__: ^jodin.Cell = nil
__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
__symmap__: ^map[string]rawptr = nil

color: ^[4]f32
data_mutex: sync.Mutex



@(export) __update_symmap__:: proc() {
	__symmap__["data_mutex"] = auto_cast &data_mutex
}
@(export) __apply_symmap__:: proc() {
	color = (cast(^[4]f32)__symmap__["color"])
}


@(export) __init__:: proc(_cell: ^jodin.Cell, _stdout: os.Handle, _stderr: os.Handle, _iopub: os.Handle, _symmap: ^map[string]rawptr) {
	__cell__ = _cell
	context = __cell__.cell_context
	__original_stdout__ = os.stdout
	__original_stderr__ = os.stderr
	__stdout__ = _stdout; os.stdout = __stdout__
	__stderr__ = _stderr; os.stderr = __stderr__
	__iopub__ = _iopub
	__symmap__ = _symmap
}

@(export) __main__:: proc() {
	context = __cell__.cell_context

	data_mutex = {}

	os.stdout = __original_stdout__
	os.stderr = __original_stderr__
}
