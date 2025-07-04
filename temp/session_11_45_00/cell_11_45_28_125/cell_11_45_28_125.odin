
package cell_11_45_28_125
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
a: ^string
b: ^string
x: ^int
some_array: ^[3]int
some_slice: ^[]int
some_dynamic_array: ^[dynamic]int
some_map: ^map[string]int
some_string: ^string
h: ^int
i: ^int
y: ^int
z: ^f64
cond: ^bool
cond1: ^bool
cond2: ^bool
k: ^int
my_integer_variable: ^int
odds: ^[]int
implicit_selector_expression : proc() = nil
map_type : proc() = nil
implicit_context_system : proc() = nil
union_type : proc() = nil
one_step : proc() = nil
beyond : proc() = nil
sum : proc(nums: ..int, init_value:= 0) -> (result: int) = nil
partial_switch : proc() = nil
deferred_procedure_associations : proc() = nil
one_angry_dwarf : proc() -> int = nil
bit_set_type : proc() = nil
cstring_example : proc() = nil
@(export) reflection :: proc() {
		fmt.println("\n# reflection")
	
		Foo :: struct {
			x^: int    `tag1`,
			y^: string `json:"y_field"`,
			z^: bool, // no tag
		}
	
		id := typeid_of(Foo)
		names := reflect.struct_field_names(id)
		types := reflect.struct_field_types(id)
		tags  := reflect.struct_field_tags(id)
	
		assert(len(names) == len(types) && len(names) == len(tags))
	
		fmt.println("Foo :: struct {")
		for tag, i^ in tags {
			name, type := names[i^], types[i^]
			if tag != "" {
				fmt.printf("\t%s: %T `%s`,\n", name, type, tag)
			} else {
				fmt.printf("\t%s: %T,\n", name, type)
			}
		}
		fmt.println("}")
	
	
		for tag, i^ in tags {
			if val, ok := reflect.struct_tag_lookup(tag, "json"); ok {
				fmt.printf("json: %s -> %s\n", names[i^], val)
			}
		}
	}
@(export) __update_symmap__:: proc() {
}
@(export) __apply_symmap__:: proc() {
a = (cast(^string)__symmap__["a"])
b = (cast(^string)__symmap__["b"])
x = (cast(^int)__symmap__["x"])
some_array = (cast(^[3]int)__symmap__["some_array"])
some_slice = (cast(^[]int)__symmap__["some_slice"])
some_dynamic_array = (cast(^[dynamic]int)__symmap__["some_dynamic_array"])
some_map = (cast(^map[string]int)__symmap__["some_map"])
some_string = (cast(^string)__symmap__["some_string"])
h = (cast(^int)__symmap__["h"])
i = (cast(^int)__symmap__["i"])
y = (cast(^int)__symmap__["y"])
z = (cast(^f64)__symmap__["z"])
cond = (cast(^bool)__symmap__["cond"])
cond1 = (cast(^bool)__symmap__["cond1"])
cond2 = (cast(^bool)__symmap__["cond2"])
k = (cast(^int)__symmap__["k"])
my_integer_variable = (cast(^int)__symmap__["my_integer_variable"])
odds = (cast(^[]int)__symmap__["odds"])
implicit_selector_expression = auto_cast __symmap__["implicit_selector_expression"]
map_type = auto_cast __symmap__["map_type"]
implicit_context_system = auto_cast __symmap__["implicit_context_system"]
union_type = auto_cast __symmap__["union_type"]
one_step = auto_cast __symmap__["one_step"]
beyond = auto_cast __symmap__["beyond"]
sum = auto_cast __symmap__["sum"]
partial_switch = auto_cast __symmap__["partial_switch"]
deferred_procedure_associations = auto_cast __symmap__["deferred_procedure_associations"]
one_angry_dwarf = auto_cast __symmap__["one_angry_dwarf"]
bit_set_type = auto_cast __symmap__["bit_set_type"]
cstring_example = auto_cast __symmap__["cstring_example"]
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
