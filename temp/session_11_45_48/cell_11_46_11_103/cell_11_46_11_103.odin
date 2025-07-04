
package cell_11_46_11_103
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
union_type : proc() = nil
@(export) using_statement :: proc() {
		fmt.println("\n# using statement")
		// using can used to bring entities declared in a scope/namespace
		// into the current scope. This can be applied to import names, struct
		// fields, procedure fields, and struct values.
	
		Vector3 :: struct{x^, y^, z^: f32}
		{
			Entity :: struct {
				position: Vector3,
				orientation: quaternion128,
			}
	
			// It can used like this:
			foo0 :: proc(entity: ^Entity) {
				fmt.println(entity.position.x^, entity.position.y^, entity.position.z^)
			}
	
			// The entity members can be brought into the procedure scope by using it:
			foo1 :: proc(entity: ^Entity) {
				using entity
				fmt.println(position.x^, position.y^, position.z^)
			}
	
			// The using can be applied to the parameter directly:
			foo2 :: proc(using entity: ^Entity) {
				fmt.println(position.x^, position.y^, position.z^)
			}
	
			// It can also be applied to sub-fields:
			foo3 :: proc(entity: ^Entity) {
				using entity.position
				fmt.println(x^, y^, z^)
			}
		}
		{
			// We can also apply the using statement to the struct fields directly,
			// making all the fields of position appear as if they on Entity itself:
			Entity :: struct {
				using position: Vector3,
				orientation: quaternion128,
			}
			foo :: proc(entity: ^Entity) {
				fmt.println(entity.x^, entity.y^, entity.z^)
			}
	
	
			// Subtype polymorphism
			// It is possible to get subtype polymorphism, similar to inheritance-like
			// functionality in C++, but without the requirement of vtables or unknown
			// struct layout:
	
			Colour :: struct {r, g, b^, a^: u8}
			Frog :: struct {
				ribbit_volume: f32,
				using entity: Entity,
				colour: Colour,
			}
	
			frog: Frog
			// Both work
			foo(&frog.entity)
			foo(&frog)
			frog.x^ = 123
	
			// Note: using can be applied to arbitrarily many things, which allows
			// the ability to have multiple subtype polymorphism (but also its issues).
	
			// Note: using’d fields can still be referred by name.
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
