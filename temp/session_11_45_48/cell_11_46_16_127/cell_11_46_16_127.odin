
package cell_11_46_16_127
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
h: ^int
some_array: ^[3]int
some_slice: ^[]int
some_dynamic_array: ^[dynamic]int
some_map: ^map[string]int
my_integer_variable: ^int
k: ^int
x: ^int
odds: ^[]int
i: ^int
cond: ^bool
cond1: ^bool
cond2: ^bool
some_string: ^string
y: ^int
z: ^f64
a: ^string
b: ^string
implicit_selector_expression : proc() = nil
implicit_context_system : proc() = nil
one_step : proc() = nil
beyond : proc() = nil
bit_set_type : proc() = nil
union_type : proc() = nil
partial_switch : proc() = nil
deferred_procedure_associations : proc() = nil
map_type : proc() = nil
sum : proc(nums: ..int, init_value:= 0) -> (result: int) = nil
one_angry_dwarf : proc() -> int = nil
cstring_example : proc() = nil
@(export) quaternions :: proc() {
		// Not just an April Fool's Joke any more, but a fully working thing!
		fmt.println("\n# quaternions")
	
		{ // Quaternion operations
			q := 1 + 2i + 3j + 4k
			r := quaternion(real=5, imag=6, jmag=7, kmag=8)
			t := q * r
			fmt.printf("(%v) * (%v) = %v\n", q, r, t)
			v := q / r
			fmt.printf("(%v) / (%v) = %v\n", q, r, v)
			u := q + r
			fmt.printf("(%v) + (%v) = %v\n", q, r, u)
			s := q - r
			fmt.printf("(%v) - (%v) = %v\n", q, r, s)
		}
		{ // The quaternion types
			q128: quaternion128 // 4xf32
			q256: quaternion256 // 4xf64
			q128 = quaternion(w=1, x^=0, y^=0, z^=0)
			q256 = 1 // quaternion(x=0, y=0, z=0, w=1)
	
			// NOTE: The internal memory layout of a quaternion is xyzw
		}
		{ // Built-in procedures
			q := 1 + 2i + 3j + 4k
			fmt.println("q =", q)
			fmt.println("real(q) =", real(q))
			fmt.println("imag(q) =", imag(q))
			fmt.println("jmag(q) =", jmag(q))
			fmt.println("kmag(q) =", kmag(q))
			fmt.println("conj(q) =", conj(q))
			fmt.println("abs(q)  =", abs(q))
		}
		{ // Conversion of a complex type to a quaternion type
			c := 1 + 2i
			q := quaternion256(c)
			fmt.println(c)
			fmt.println(q)
		}
		{ // Memory layout of Quaternions
			q := 1 + 2i + 3j + 4k
			a := transmute([4]f64)q
			fmt.println("Quaternion memory layout: xyzw/(ijkr)")
			fmt.println(q) // 1.000+2.000i+3.000j+4.000k
			fmt.println(a) // [2.000, 3.000, 4.000, 1.000]
		}
	}
@(export) __update_symmap__:: proc() {
}
@(export) __apply_symmap__:: proc() {
h = (cast(^int)__symmap__["h"])
some_array = (cast(^[3]int)__symmap__["some_array"])
some_slice = (cast(^[]int)__symmap__["some_slice"])
some_dynamic_array = (cast(^[dynamic]int)__symmap__["some_dynamic_array"])
some_map = (cast(^map[string]int)__symmap__["some_map"])
my_integer_variable = (cast(^int)__symmap__["my_integer_variable"])
k = (cast(^int)__symmap__["k"])
x = (cast(^int)__symmap__["x"])
odds = (cast(^[]int)__symmap__["odds"])
i = (cast(^int)__symmap__["i"])
cond = (cast(^bool)__symmap__["cond"])
cond1 = (cast(^bool)__symmap__["cond1"])
cond2 = (cast(^bool)__symmap__["cond2"])
some_string = (cast(^string)__symmap__["some_string"])
y = (cast(^int)__symmap__["y"])
z = (cast(^f64)__symmap__["z"])
a = (cast(^string)__symmap__["a"])
b = (cast(^string)__symmap__["b"])
implicit_selector_expression = auto_cast __symmap__["implicit_selector_expression"]
implicit_context_system = auto_cast __symmap__["implicit_context_system"]
one_step = auto_cast __symmap__["one_step"]
beyond = auto_cast __symmap__["beyond"]
bit_set_type = auto_cast __symmap__["bit_set_type"]
union_type = auto_cast __symmap__["union_type"]
partial_switch = auto_cast __symmap__["partial_switch"]
deferred_procedure_associations = auto_cast __symmap__["deferred_procedure_associations"]
map_type = auto_cast __symmap__["map_type"]
sum = auto_cast __symmap__["sum"]
one_angry_dwarf = auto_cast __symmap__["one_angry_dwarf"]
cstring_example = auto_cast __symmap__["cstring_example"]
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
