
package cell_11_46_14_119
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
x: ^int
some_array: ^[3]int
some_slice: ^[]int
some_dynamic_array: ^[dynamic]int
some_map: ^map[string]int
some_string: ^string
y: ^int
z: ^f64
a: ^string
b: ^string
i: ^int
h: ^int
odds: ^[]int
k: ^int
my_integer_variable: ^int
cond: ^bool
cond1: ^bool
cond2: ^bool
one_angry_dwarf : proc() -> int = nil
implicit_context_system : proc() = nil
sum : proc(nums: ..int, init_value:= 0) -> (result: int) = nil
implicit_selector_expression : proc() = nil
partial_switch : proc() = nil
map_type : proc() = nil
one_step : proc() = nil
beyond : proc() = nil
union_type : proc() = nil
@(export) cstring_example :: proc() {
	fmt.println("\n# cstring_example")

	W :: "Hellope"
	X :: cstring(W)
	Y :: string(X)

	w := W
	_ = w
	x: cstring = X
	y: string = Y
	z := string(x)
	fmt.println(x, y, z)
	fmt.println(len(x), len(y), len(z))
	fmt.println(len(W), len(X), len(Y))
	// IMPORTANT NOTE for cstring variables
	// len(cstring) is O(N)
	// cast(string)cstring is O(N)
}
@(export) __update_symmap__:: proc() {
}
@(export) __apply_symmap__:: proc() {
x = (cast(^int)__symmap__["x"])
some_array = (cast(^[3]int)__symmap__["some_array"])
some_slice = (cast(^[]int)__symmap__["some_slice"])
some_dynamic_array = (cast(^[dynamic]int)__symmap__["some_dynamic_array"])
some_map = (cast(^map[string]int)__symmap__["some_map"])
some_string = (cast(^string)__symmap__["some_string"])
y = (cast(^int)__symmap__["y"])
z = (cast(^f64)__symmap__["z"])
a = (cast(^string)__symmap__["a"])
b = (cast(^string)__symmap__["b"])
i = (cast(^int)__symmap__["i"])
h = (cast(^int)__symmap__["h"])
odds = (cast(^[]int)__symmap__["odds"])
k = (cast(^int)__symmap__["k"])
my_integer_variable = (cast(^int)__symmap__["my_integer_variable"])
cond = (cast(^bool)__symmap__["cond"])
cond1 = (cast(^bool)__symmap__["cond1"])
cond2 = (cast(^bool)__symmap__["cond2"])
one_angry_dwarf = auto_cast __symmap__["one_angry_dwarf"]
implicit_context_system = auto_cast __symmap__["implicit_context_system"]
sum = auto_cast __symmap__["sum"]
implicit_selector_expression = auto_cast __symmap__["implicit_selector_expression"]
partial_switch = auto_cast __symmap__["partial_switch"]
map_type = auto_cast __symmap__["map_type"]
one_step = auto_cast __symmap__["one_step"]
beyond = auto_cast __symmap__["beyond"]
union_type = auto_cast __symmap__["union_type"]
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
	os.stdout = __original_stdout__
	os.stderr = __original_stderr__
}
