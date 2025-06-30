
package cell_11_57_42_3

import "shared:jodin"
import "core:io"
import "core:os"
import "core:fmt"

@(export) __cell__: ^jodin.Cell = nil
__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
__symmap__: ^map[string]rawptr = nil

m: []int



@(export) __update_symmap__:: proc() {
	__symmap__["m"] = auto_cast &m
}
@(export) __apply_symmap__:: proc() {
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

	m = make([]int, 10)
	 for i in 0 ..< 10 do m[i] = i
	 for i in 0 ..< 20 do fmt.println(m[i])

	os.stdout = __original_stdout__
	os.stderr = __original_stderr__
}
