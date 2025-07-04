
package cell_11_12_43_129
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
k: ^int
a: ^string
b: ^string
y: ^int
z: ^f64
i: ^int
cond: ^bool
cond1: ^bool
cond2: ^bool
x: ^int
some_string: ^string
odds: ^[]int
my_integer_variable: ^int
h: ^int
union_type : proc() = nil
deferred_procedure_associations : proc() = nil
bit_set_type : proc() = nil
one_step : proc() = nil
beyond : proc() = nil
sum : proc(nums: ..int, init_value:= 0) -> (result: int) = nil
one_angry_dwarf : proc() -> int = nil
partial_switch : proc() = nil
implicit_selector_expression : proc() = nil
cstring_example : proc() = nil
implicit_context_system : proc() = nil
map_type : proc() = nil
@(export) unroll_for_statement :: proc() {
		fmt.println("\n#'#unroll for' statements")
	
		// '#unroll for' works the same as if the 'inline' prefix did not
		// exist but these ranged loops are explicitly unrolled which can
		// be very very useful for certain optimizations
	
		fmt.println("Ranges")
		#unroll for x^, i^ in 1..<4 {
			fmt.println(x^, i^)
		}
	
		fmt.println("Strings")
		#unroll for r, i^ in "Hello, 世界" {
			fmt.println(r, i^)
		}
	
		fmt.println("Arrays")
		#unroll for elem, idx in ([4]int{1, 4, 9, 16}) {
			fmt.println(elem, idx)
		}
	
	
		Foo_Enum :: enum {
			A = 1,
			B,
			C = 6,
			D,
		}
		fmt.println("Enum types")
		#unroll for elem, idx in Foo_Enum {
			fmt.println(elem, idx)
		}
	}
@(export) __update_symmap__:: proc() {
}
@(export) __apply_symmap__:: proc() {
some_array = (cast(^[3]int)__symmap__["some_array"])
some_slice = (cast(^[]int)__symmap__["some_slice"])
some_dynamic_array = (cast(^[dynamic]int)__symmap__["some_dynamic_array"])
some_map = (cast(^map[string]int)__symmap__["some_map"])
k = (cast(^int)__symmap__["k"])
a = (cast(^string)__symmap__["a"])
b = (cast(^string)__symmap__["b"])
y = (cast(^int)__symmap__["y"])
z = (cast(^f64)__symmap__["z"])
i = (cast(^int)__symmap__["i"])
cond = (cast(^bool)__symmap__["cond"])
cond1 = (cast(^bool)__symmap__["cond1"])
cond2 = (cast(^bool)__symmap__["cond2"])
x = (cast(^int)__symmap__["x"])
some_string = (cast(^string)__symmap__["some_string"])
odds = (cast(^[]int)__symmap__["odds"])
my_integer_variable = (cast(^int)__symmap__["my_integer_variable"])
h = (cast(^int)__symmap__["h"])
union_type = auto_cast __symmap__["union_type"]
deferred_procedure_associations = auto_cast __symmap__["deferred_procedure_associations"]
bit_set_type = auto_cast __symmap__["bit_set_type"]
one_step = auto_cast __symmap__["one_step"]
beyond = auto_cast __symmap__["beyond"]
sum = auto_cast __symmap__["sum"]
one_angry_dwarf = auto_cast __symmap__["one_angry_dwarf"]
partial_switch = auto_cast __symmap__["partial_switch"]
implicit_selector_expression = auto_cast __symmap__["implicit_selector_expression"]
cstring_example = auto_cast __symmap__["cstring_example"]
implicit_context_system = auto_cast __symmap__["implicit_context_system"]
map_type = auto_cast __symmap__["map_type"]
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
