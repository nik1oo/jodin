
package cell_11_27_13_111
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
k: ^int
my_integer_variable: ^int
cond: ^bool
cond1: ^bool
cond2: ^bool
h: ^int
a: ^string
b: ^string
some_array: ^[3]int
some_slice: ^[]int
some_dynamic_array: ^[dynamic]int
some_map: ^map[string]int
odds: ^[]int
y: ^int
z: ^f64
x: ^int
some_string: ^string
i: ^int
one_step : proc() = nil
beyond : proc() = nil
implicit_context_system : proc() = nil
union_type : proc() = nil
one_angry_dwarf : proc() -> int = nil
sum : proc(nums: ..int, init_value:= 0) -> (result: int) = nil
@(export) array_programming :: proc() {
		fmt.println("\n# array programming")
		{
			a := [3]f32{1, 2, 3}
			b := [3]f32{5, 6, 7}
			c := a * b
			d := a + b
			e := 1 +  (c - d) / 2
			fmt.printf("%.1f\n", e) // [0.5, 3.0, 6.5]
		}
	
		{
			a := [3]f32{1, 2, 3}
			b := swizzle(a, 2, 1, 0)
			assert(b == [3]f32{3, 2, 1})
	
			c := swizzle(a, 0, 0)
			assert(c == [2]f32{1, 1})
			assert(c == 1)
		}
	
		{
			Vector3 :: distinct [3]f32
			a := Vector3{1, 2, 3}
			b := Vector3{5, 6, 7}
			c := (a * b)/2 + 1
			d := c.x^ + c.y^ + c.z^
			fmt.printf("%.1f\n", d) // 22.0
	
			cross :: proc(a, b: Vector3) -> Vector3 {
				i := swizzle(a, 1, 2, 0) * swizzle(b, 2, 0, 1)
				j := swizzle(a, 2, 0, 1) * swizzle(b, 1, 2, 0)
				return i - j
			}
	
			cross_shorter :: proc(a^, b^: Vector3) -> Vector3 {
				i := a^.yzx * b^.zxy
				j := a^.zxy * b^.yzx
				return i - j
			}
	
			blah :: proc(a^: Vector3) -> f32 {
				return a^.x^ + a^.y^ + a^.z^
			}
	
			x := cross(a^, b^)
			fmt.println(x)
			fmt.println(blah(x))
		}
	}
@(export) __update_symmap__:: proc() {
}
@(export) __apply_symmap__:: proc() {
k = (cast(^int)__symmap__["k"])
my_integer_variable = (cast(^int)__symmap__["my_integer_variable"])
cond = (cast(^bool)__symmap__["cond"])
cond1 = (cast(^bool)__symmap__["cond1"])
cond2 = (cast(^bool)__symmap__["cond2"])
h = (cast(^int)__symmap__["h"])
a = (cast(^string)__symmap__["a"])
b = (cast(^string)__symmap__["b"])
some_array = (cast(^[3]int)__symmap__["some_array"])
some_slice = (cast(^[]int)__symmap__["some_slice"])
some_dynamic_array = (cast(^[dynamic]int)__symmap__["some_dynamic_array"])
some_map = (cast(^map[string]int)__symmap__["some_map"])
odds = (cast(^[]int)__symmap__["odds"])
y = (cast(^int)__symmap__["y"])
z = (cast(^f64)__symmap__["z"])
x = (cast(^int)__symmap__["x"])
some_string = (cast(^string)__symmap__["some_string"])
i = (cast(^int)__symmap__["i"])
one_step = auto_cast __symmap__["one_step"]
beyond = auto_cast __symmap__["beyond"]
implicit_context_system = auto_cast __symmap__["implicit_context_system"]
union_type = auto_cast __symmap__["union_type"]
one_angry_dwarf = auto_cast __symmap__["one_angry_dwarf"]
sum = auto_cast __symmap__["sum"]
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
	os.stdout = __original_stdout__
	os.stderr = __original_stderr__
}
