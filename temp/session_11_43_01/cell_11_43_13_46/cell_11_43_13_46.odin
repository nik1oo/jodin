#+feature dynamic-literals

package cell_11_43_13_46
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
my_integer_variable: ^int
x: ^int
some_string: ^string
i: ^int
y: ^int
z: ^f64
a: ^string
b: ^string
k: ^int
h: ^int
some_array: [3]int
some_slice: []int
some_dynamic_array: [dynamic]int
some_map: map[string]int
@(export) __update_symmap__:: proc() {
__symmap__["some_array"] = auto_cast &some_array
__symmap__["some_slice"] = auto_cast &some_slice
__symmap__["some_dynamic_array"] = auto_cast &some_dynamic_array
__symmap__["some_map"] = auto_cast &some_map
}
@(export) __apply_symmap__:: proc() {
my_integer_variable = (cast(^int)__symmap__["my_integer_variable"])
x = (cast(^int)__symmap__["x"])
some_string = (cast(^string)__symmap__["some_string"])
i = (cast(^int)__symmap__["i"])
y = (cast(^int)__symmap__["y"])
z = (cast(^f64)__symmap__["z"])
a = (cast(^string)__symmap__["a"])
b = (cast(^string)__symmap__["b"])
k = (cast(^int)__symmap__["k"])
h = (cast(^int)__symmap__["h"])
}















X :: "what"





Y : int : 123
Z :: Y + 7



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
	some_array = [3]int{1, 4, 9}
	some_slice = []int{1, 4, 9}
	some_dynamic_array = [dynamic]int{1, 4, 9}
	some_map = map[string]int{"A" = 1, "C" = 9, "B" = 4}
	 some_string^ = "Hello, 世界"
	for character in some_string^ { // Strings are assumed to be UTF-8
	    fmt.println(character)
	}
	for value in some_array {
    fmt.println(value)
}
	for value in some_slice {
    fmt.println(value)
}
	 defer delete(some_dynamic_array)
	for value in some_dynamic_array {
    fmt.println(value)
}
	 defer delete(some_map)
	for key in some_map {
    fmt.println(key)
}
	os.stdout = __original_stdout__
	os.stderr = __original_stderr__
}
