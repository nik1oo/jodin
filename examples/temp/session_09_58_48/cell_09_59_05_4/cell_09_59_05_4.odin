
package cell_09_59_05_4

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

data_mutex: ^sync.Mutex
color: ^[4]f32
ok: ^bool
window: ^glfw.WindowHandle



@(export) __update_symmap__:: proc() {
}
@(export) __apply_symmap__:: proc() {
	data_mutex = (cast(^sync.Mutex)__symmap__["data_mutex"])
	color = (cast(^[4]f32)__symmap__["color"])
	ok = (cast(^bool)__symmap__["ok"])
	window = (cast(^glfw.WindowHandle)__symmap__["window"])
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

	 sync.mutex_lock(&data_mutex^)
	 defer sync.mutex_unlock(&data_mutex^)
	 color^ = { 1, 1, 0, 0 }

	os.stdout = __original_stdout__
	os.stderr = __original_stderr__
}
