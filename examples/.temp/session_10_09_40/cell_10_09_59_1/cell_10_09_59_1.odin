
package cell_10_09_59_1
import "shared:jodin"
import "core:io"
import "core:os"
import "core:sync"
import gp "shared:gnuplot"
@(export) __cell__: ^jodin.Cell = nil
__data_mutex__: ^sync.Ticket_Mutex = nil
__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
__symmap__: ^map[string]rawptr = nil
canvas: ^gp.Canvas
@(export) __update_symmap__:: proc() {
__symmap__["canvas"] = auto_cast canvas
}
@(export) __apply_symmap__:: proc() {
}

@(export) __init__:: proc(_cell: ^jodin.Cell, _stdout: os.Handle, _stderr: os.Handle, _iopub: os.Handle, _symmap: ^map[string]rawptr) {
	__data_mutex__ = &_cell.session.data_mutex
	sync.ticket_mutex_lock(__data_mutex__); defer sync.ticket_mutex_unlock(__data_mutex__)
	__cell__ = _cell
	sync.mutex_lock(&__cell__.mutex); defer sync.mutex_unlock(&__cell__.mutex)
	context = __cell__.cell_context
	__original_stdout__ = os.stdout
	__original_stderr__ = os.stderr
	__stdout__ = _stdout; os.stdout = __stdout__
	__stderr__ = _stderr; os.stderr = __stderr__
	__iopub__ = _iopub
	__symmap__ = _symmap
}
@(export) __main__:: proc() {
	sync.ticket_mutex_lock(__data_mutex__); defer sync.ticket_mutex_unlock(__data_mutex__)
	sync.mutex_lock(&__cell__.mutex); defer sync.mutex_unlock(&__cell__.mutex)
	context = __cell__.cell_context
	canvas = gp.new_canvas()
	 gp.set_terminal_pngcairo(canvas, size = {600, 400})
	 gp.set_output(canvas, "plot.png")
	 gp.plot(canvas, expression = gp.sin("x"))
	 gp.render_canvas(canvas)
	 jodin.display_image(path="plot.png")
	os.stdout = __original_stdout__
	os.stderr = __original_stderr__
}
