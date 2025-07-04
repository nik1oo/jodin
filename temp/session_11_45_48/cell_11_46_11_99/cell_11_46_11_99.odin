
package cell_11_46_11_99
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
sum : proc(nums: ..int, init_value:= 0) -> (result: int) = nil
one_step : proc() = nil
beyond : proc() = nil
@(export) struct_type :: proc() {
		fmt.println("\n# struct type")
		// A struct is a record type in Odin. It is a collection of fields.
		// Struct fields are accessed by using a dot:
		{
			Vector2 :: struct {
				x^: f32,
				y^: f32,
			}
			v := Vector2{1, 2}
			v.x^ = 4
			fmt.println(v.x^)
	
			// Struct fields can be accessed through a struct pointer:
	
			v = Vector2{1, 2}
			p := &v
			p.x^ = 1335
			fmt.println(v)
	
			// We could write p^.x, however, it is nice to abstract the ability
			// to not explicitly dereference the pointer. This is very useful when
			// refactoring code to use a pointer rather than a value, and vice versa.
		}
		{
			// A struct literal can be denoted by providing the struct’s type
			// followed by {}. A struct literal must either provide all the
			// arguments or none:
			Vector3 :: struct {
				x^, y^, z^: f32,
			}
			v: Vector3
			v = Vector3{} // Zero value
			v = Vector3{1, 4, 9}
	
			// You can list just a subset of the fields if you specify the
			// field by name (the order of the named fields does not matter):
			v = Vector3{z^=1, y^=2}
			assert(v.x^ == 0)
			assert(v.y^ == 2)
			assert(v.z^ == 1)
		}
		{
			// Structs can tagged with different memory layout and alignment requirements:
	
			a :: struct #align(4)  {} // align to 4 bytes
			b :: struct #packed    {} // remove padding between fields
			c :: struct #raw_union {} // all fields share the same offset (0). This is the same as C's union
		}
	
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
sum = auto_cast __symmap__["sum"]
one_step = auto_cast __symmap__["one_step"]
beyond = auto_cast __symmap__["beyond"]
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
