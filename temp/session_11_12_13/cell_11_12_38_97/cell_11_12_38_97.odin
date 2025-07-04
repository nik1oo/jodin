
package cell_11_12_38_97
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
some_array: ^[3]int
some_slice: ^[]int
some_dynamic_array: ^[dynamic]int
some_map: ^map[string]int
x: ^int
h: ^int
i: ^int
cond: ^bool
cond1: ^bool
cond2: ^bool
odds: ^[]int
y: ^int
z: ^f64
my_integer_variable: ^int
a: ^string
b: ^string
some_string: ^string
k: ^int
sum : proc(nums: ..int, init_value:= 0) -> (result: int) = nil
one_step : proc() = nil
beyond : proc() = nil
one_angry_dwarf : proc() -> int = nil
@(export) explicit_procedure_overloading :: proc() {
		fmt.println("\n# explicit procedure overloading")
	
		add_ints :: proc(a^, b^: int) -> int {
			x := a^ + b^
			fmt.println("add_ints", x)
			return x
		}
		add_floats :: proc(a^, b^: f32) -> f32 {
			x := a^ + b^
			fmt.println("add_floats", x)
			return x
		}
		add_numbers :: proc(a^: int, b^: f32, c: u8) -> int {
			x := int(a^) + int(b^) + int(c)
			fmt.println("add_numbers", x)
			return x
		}
	
		add :: proc{add_ints, add_floats, add_numbers}
	
		add(int(1), int(2))
		add(f32(1), f32(2))
		add(int(1), f32(2), u8(3))
	
		add(1, 2)     // untyped ints coerce to int tighter than f32
		add(1.0, 2.0) // untyped floats coerce to f32 tighter than int
		add(1, 2, 3)  // three parameters
	
		// Ambiguous answers
		// add(1.0, 2)
		// add(1, 2.0)
	}
@(export) __update_symmap__:: proc() {
}
@(export) __apply_symmap__:: proc() {
some_array = (cast(^[3]int)__symmap__["some_array"])
some_slice = (cast(^[]int)__symmap__["some_slice"])
some_dynamic_array = (cast(^[dynamic]int)__symmap__["some_dynamic_array"])
some_map = (cast(^map[string]int)__symmap__["some_map"])
x = (cast(^int)__symmap__["x"])
h = (cast(^int)__symmap__["h"])
i = (cast(^int)__symmap__["i"])
cond = (cast(^bool)__symmap__["cond"])
cond1 = (cast(^bool)__symmap__["cond1"])
cond2 = (cast(^bool)__symmap__["cond2"])
odds = (cast(^[]int)__symmap__["odds"])
y = (cast(^int)__symmap__["y"])
z = (cast(^f64)__symmap__["z"])
my_integer_variable = (cast(^int)__symmap__["my_integer_variable"])
a = (cast(^string)__symmap__["a"])
b = (cast(^string)__symmap__["b"])
some_string = (cast(^string)__symmap__["some_string"])
k = (cast(^int)__symmap__["k"])
sum = auto_cast __symmap__["sum"]
one_step = auto_cast __symmap__["one_step"]
beyond = auto_cast __symmap__["beyond"]
one_angry_dwarf = auto_cast __symmap__["one_angry_dwarf"]
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
