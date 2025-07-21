
package cell_17_45_54_97
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
some_string: ^string
some_array: ^[3]int
i: ^int
x: ^int
cond: ^bool
cond1: ^bool
cond2: ^bool
y: ^int
z: ^f64
some_slice: ^[]int
a: ^string
b: ^string
some_map: ^map[string]int
some_dynamic_array: ^[dynamic]int
h: ^int
my_integer_variable: ^int
foo0 : proc() -> int = nil
foo1 : proc() -> (a: int) = nil
one_angry_dwarf : proc() -> int = nil
foo2 : proc() -> (a, b: int) = nil
one_step : proc() = nil
beyond : proc() = nil
@(export) __update_symmap__:: proc() {
}
@(export) __apply_symmap__:: proc() {
k = (cast(^int)__symmap__["k"])
some_string = (cast(^string)__symmap__["some_string"])
some_array = (cast(^[3]int)__symmap__["some_array"])
i = (cast(^int)__symmap__["i"])
x = (cast(^int)__symmap__["x"])
cond = (cast(^bool)__symmap__["cond"])
cond1 = (cast(^bool)__symmap__["cond1"])
cond2 = (cast(^bool)__symmap__["cond2"])
y = (cast(^int)__symmap__["y"])
z = (cast(^f64)__symmap__["z"])
some_slice = (cast(^[]int)__symmap__["some_slice"])
a = (cast(^string)__symmap__["a"])
b = (cast(^string)__symmap__["b"])
some_map = (cast(^map[string]int)__symmap__["some_map"])
some_dynamic_array = (cast(^[dynamic]int)__symmap__["some_dynamic_array"])
h = (cast(^int)__symmap__["h"])
my_integer_variable = (cast(^int)__symmap__["my_integer_variable"])
foo0 = auto_cast __symmap__["foo0"]
foo1 = auto_cast __symmap__["foo1"]
one_angry_dwarf = auto_cast __symmap__["one_angry_dwarf"]
foo2 = auto_cast __symmap__["foo2"]
one_step = auto_cast __symmap__["one_step"]
beyond = auto_cast __symmap__["beyond"]
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
	 fmt.println("foo0 =", foo0())
	 fmt.println("foo1 =", foo1())
	 fmt.println("foo2 =", foo2())
	os.stdout = __original_stdout__
	os.stderr = __original_stderr__
}
