
package cell_09_58_59_3

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
ok: bool
window: glfw.WindowHandle



@(export) __update_symmap__:: proc() {
	__symmap__["ok"] = auto_cast &ok
	__symmap__["window"] = auto_cast &window
}
@(export) __apply_symmap__:: proc() {
	data_mutex = (cast(^sync.Mutex)__symmap__["data_mutex"])
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

	ok = bool(glfw.Init())
	window = glfw.CreateWindow(920, 920, "jodin glfw example", nil, nil)
	 if ! ok do return
	 glfw.MakeContextCurrent(window)
	 gl.load_up_to(4, 5, glfw.gl_set_proc_address)
	 for (!glfw.WindowShouldClose(window)) {
    sync.mutex_lock(&data_mutex^)
    defer sync.mutex_unlock(&data_mutex^)
    gl.ClearColor(color^.x, color^.y, color^.z, color^.w)
    gl.Clear(gl.COLOR_BUFFER_BIT)
    glfw.SwapBuffers(window)
    glfw.PollEvents() }
	 glfw.Terminate()

	os.stdout = __original_stdout__
	os.stderr = __original_stderr__
}
