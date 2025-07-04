
package cell_11_38_06_48
import "shared:jodin"
import "core:io"
import "core:os"
import "core:sync"















		import "core:fmt"
		import "core:mem"
		import "core:thread"
		import "core:time"
		import "core:reflect"
		import "base:runtime"
		import "base:intrinsics"
		import "core:math/big"








@(export) __cell__: ^jodin.Cell = nil
__data_mutex__: ^sync.Ticket_Mutex = nil
__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
__symmap__: ^map[string]rawptr = nil
y: ^int
z: ^f64
k: ^int
my_integer_variable: ^int
i: ^int
some_string: ^string
some_array: ^[3]int
some_slice: ^[]int
some_dynamic_array: ^[dynamic]int
some_map: ^map[string]int
x: ^int
a: ^string
b: ^string
h: ^int
@(export) __update_symmap__:: proc() {
}
@(export) __apply_symmap__:: proc() {
y = (cast(^int)__symmap__["y"])
z = (cast(^f64)__symmap__["z"])
k = (cast(^int)__symmap__["k"])
my_integer_variable = (cast(^int)__symmap__["my_integer_variable"])
i = (cast(^int)__symmap__["i"])
some_string = (cast(^string)__symmap__["some_string"])
some_array = (cast(^[3]int)__symmap__["some_array"])
some_slice = (cast(^[]int)__symmap__["some_slice"])
some_dynamic_array = (cast(^[dynamic]int)__symmap__["some_dynamic_array"])
some_map = (cast(^map[string]int)__symmap__["some_map"])
x = (cast(^int)__symmap__["x"])
a = (cast(^string)__symmap__["a"])
b = (cast(^string)__symmap__["b"])
h = (cast(^int)__symmap__["h"])
}








Y : int : 123
Z :: Y + 7








X :: "what"








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
	for character, index in some_string^ {
	    fmt.println(index, character)
	}
	for value, index in some_array^ {
	    fmt.println(index, value)
	}
	for value, index in some_slice^ {
	    fmt.println(index, value)
	}
	for value, index in some_dynamic_array^ {
	    fmt.println(index, value)
	}
	for key, value in some_map^ {
	    fmt.println(key, value)
	}
	os.stdout = __original_stdout__
	os.stderr = __original_stderr__
}
