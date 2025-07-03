

		package cell_14_11_19_113

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

			a: ^string

			b: ^string

			i: ^int

			my_integer_variable: ^int

			cond: ^bool

			cond1: ^bool

			cond2: ^bool

			some_string: ^string

			y: ^int

			z: ^f64

			k: ^int

			h: ^int

			odds: ^[]int

			one_angry_dwarf : proc() -> int = nil

			one_step : proc() = nil

			beyond : proc() = nil

			sum : proc(nums: ..int, init_value:= 0) -> (result: int) = nil

			implicit_context_system : proc() = nil

			@(export) map_type :: proc() {
	fmt.println("\n# map type")

	m := make(map[string]int)
	defer delete(m)

	m["Bob"] = 2
	m["Ted"] = 5
	fmt.println(m["Bob"])

	delete_key(&m, "Ted")

	// If an element of a key does not exist, the zero value of the
	// element will be returned. To check to see if an element exists
	// can be done in two ways:
	elem, ok := m["Bob"]
	exists := "Bob" in m
	_, _ = elem, ok
	_ = exists
}

		@(export) __update_symmap__:: proc() {

		}

		@(export) __apply_symmap__:: proc() {

		x = (cast(^int)__symmap__["x"])
	

		a = (cast(^string)__symmap__["a"])
	

		b = (cast(^string)__symmap__["b"])
	

		i = (cast(^int)__symmap__["i"])
	

		my_integer_variable = (cast(^int)__symmap__["my_integer_variable"])
	

		cond = (cast(^bool)__symmap__["cond"])
	

		cond1 = (cast(^bool)__symmap__["cond1"])
	

		cond2 = (cast(^bool)__symmap__["cond2"])
	

		some_string = (cast(^string)__symmap__["some_string"])
	

		y = (cast(^int)__symmap__["y"])
	

		z = (cast(^f64)__symmap__["z"])
	

		k = (cast(^int)__symmap__["k"])
	

		h = (cast(^int)__symmap__["h"])
	

		odds = (cast(^[]int)__symmap__["odds"])
	

		one_angry_dwarf = auto_cast __symmap__["one_angry_dwarf"]

		one_step = auto_cast __symmap__["one_step"]

		beyond = auto_cast __symmap__["beyond"]

		sum = auto_cast __symmap__["sum"]

		implicit_context_system = auto_cast __symmap__["implicit_context_system"]

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
