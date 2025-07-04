
package cell_11_46_11_101
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
@(export) union_type :: proc() {
	fmt.println("\n# union type")
	{
		val: union{int, bool}
		val = 137
		if i, ok := val.(int); ok {
			fmt.println(i)
		}
		val = true
		fmt.println(val)

		val = nil

		switch v in val {
		case int:  fmt.println("int",  v)
		case bool: fmt.println("bool", v)
		case:      fmt.println("nil")
		}
	}
	{
		// There is a duality between `any` and `union`
		// An `any` has a pointer to the data and allows for any type (open)
		// A `union` has as binary blob to store the data and allows only certain types (closed)
		// The following code is with `any` but has the same syntax
		val: any
		val = 137
		if i, ok := val.(int); ok {
			fmt.println(i)
		}
		val = true
		fmt.println(val)

		val = nil

		switch v in val {
		case int:  fmt.println("int",  v)
		case bool: fmt.println("bool", v)
		case:      fmt.println("nil")
		}
	}

	Vector3 :: distinct [3]f32
	Quaternion :: distinct quaternion128

	// More realistic examples
	{
		// NOTE(bill): For the above basic examples, you may not have any
		// particular use for it. However, my main use for them is not for these
		// simple cases. My main use is for hierarchical types. Many prefer
		// subtyping, embedding the base data into the derived types. Below is
		// an example of this for a basic game Entity.

		Entity :: struct {
			id:          u64,
			name:        string,
			position:    Vector3,
			orientation: Quaternion,

			derived: any,
		}

		Frog :: struct {
			using entity: Entity,
			jump_height:  f32,
		}

		Monster :: struct {
			using entity: Entity,
			is_robot:     bool,
			is_zombie:    bool,
		}

		// See `parametric_polymorphism` procedure for details
		new_entity :: proc($T: typeid) -> ^Entity {
			t := new(T)
			t.derived = t^
			return t
		}

		entity := new_entity(Monster)

		switch e in entity.derived {
		case Frog:
			fmt.println("Ribbit")
		case Monster:
			if e.is_robot  { fmt.println("Robotic") }
			if e.is_zombie { fmt.println("Grrrr!")  }
			fmt.println("I'm a monster")
		}
	}

	{
		// NOTE(bill): A union can be used to achieve something similar. Instead
		// of embedding the base data into the derived types, the derived data
		// in embedded into the base type. Below is the same example of the
		// basic game Entity but using an union.

		Entity :: struct {
			id:          u64,
			name:        string,
			position:    Vector3,
			orientation: Quaternion,

			derived: union {Frog, Monster},
		}

		Frog :: struct {
			using entity: ^Entity,
			jump_height:  f32,
		}

		Monster :: struct {
			using entity: ^Entity,
			is_robot:     bool,
			is_zombie:    bool,
		}

		// See `parametric_polymorphism` procedure for details
		new_entity :: proc($T: typeid) -> ^Entity {
			t := new(Entity)
			t.derived = T{entity = t}
			return t
		}

		entity := new_entity(Monster)

		switch e in entity.derived {
		case Frog:
			fmt.println("Ribbit")
		case Monster:
			if e.is_robot  { fmt.println("Robotic") }
			if e.is_zombie { fmt.println("Grrrr!")  }
		}

		// NOTE(bill): As you can see, the usage code has not changed, only its
		// memory layout. Both approaches have their own advantages but they can
		// be used together to achieve different results. The subtyping approach
		// can allow for a greater control of the memory layout and memory
		// allocation, e.g. storing the derivatives together. However, this is
		// also its disadvantage. You must either preallocate arrays for each
		// derivative separation (which can be easily missed) or preallocate a
		// bunch of "raw" memory; determining the maximum size of the derived
		// types would require the aid of metaprogramming. Unions solve this
		// particular problem as the data is stored with the base data.
		// Therefore, it is possible to preallocate, e.g. [100]Entity.

		// It should be noted that the union approach can have the same memory
		// layout as the any and with the same type restrictions by using a
		// pointer type for the derivatives.

		/*
			Entity :: struct {
				...
				derived: union{^Frog, ^Monster},
			}

			Frog :: struct {
				using entity: Entity,
				...
			}
			Monster :: struct {
				using entity: Entity,
				...

			}
			new_entity :: proc(T: type) -> ^Entity {
				t := new(T)
				t.derived = t
				return t
			}
		*/
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
