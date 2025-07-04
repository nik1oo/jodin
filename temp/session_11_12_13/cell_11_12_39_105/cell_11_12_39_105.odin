
package cell_11_12_39_105
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
union_type : proc() = nil
one_angry_dwarf : proc() -> int = nil
@(export) implicit_context_system :: proc() {
	fmt.println("\n# implicit context system")
	// In each scope, there is an implicit value named context. This
	// context variable is local to each scope and is implicitly passed
	// by pointer to any procedure call in that scope (if the procedure
	// has the Odin calling convention).

	// The main purpose of the implicit context system is for the ability
	// to intercept third-party code and libraries and modify their
	// functionality. One such case is modifying how a library allocates
	// something or logs something. In C, this was usually achieved with
	// the library defining macros which could be overridden so that the
	// user could define what he wanted. However, not many libraries
	// supported this in many languages by default which meant intercepting
	// third-party code to see what it does and to change how it does it is
	// not possible.

	c := context // copy the current scope's context

	context.user_index = 456
	{
		context.allocator = my_custom_allocator()
		context.user_index = 123
		what_a_fool_believes() // the `context` for this scope is implicitly passed to `what_a_fool_believes`
	}

	// `context` value is local to the scope it is in
	assert(context.user_index == 456)

	what_a_fool_believes :: proc() {
		c := context // this `context` is the same as the parent procedure that it was called from
		// From this example, context.user_index == 123
		// A context.allocator is assigned to the return value of `my_custom_allocator()`
		assert(context.user_index == 123)

		// The memory management procedure use the `context.allocator` by
		// default unless explicitly specified otherwise
		china_grove := new(int)
		free(china_grove)

		_ = c
	}

	my_custom_allocator :: mem.nil_allocator
	_ = c

	// By default, the context value has default values for its parameters which is
	// decided in the package runtime. What the defaults are are compiler specific.

	// To see what the implicit context value contains, please see the following
	// definition in package runtime.
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
union_type = auto_cast __symmap__["union_type"]
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
