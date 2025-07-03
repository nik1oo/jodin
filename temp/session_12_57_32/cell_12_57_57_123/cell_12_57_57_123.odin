

		package cell_12_57_57_123

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

			k: ^int

			my_integer_variable: ^int

			some_string: ^string

			cond: ^bool

			cond1: ^bool

			cond2: ^bool

			odds: ^[]int

			h: ^int

			y: ^int

			z: ^f64

			i: ^int

			implicit_context_system : proc() = nil

			partial_switch : proc() = nil

			map_type : proc() = nil

			sum : proc(nums: ..int, init_value:= 0) -> (result: int) = nil

			implicit_selector_expression : proc() = nil

			one_step : proc() = nil

			beyond : proc() = nil

			one_angry_dwarf : proc() -> int = nil

			@(export) deferred_procedure_associations :: proc() {
	fmt.println("\n# deferred procedure associations")

	@(deferred_out=closure)
	open :: proc(s: string) -> bool {
		fmt.println(s)
		return true
	}

	closure :: proc(ok: bool) {
		fmt.println("Goodbye?", ok)
	}

	if open("Welcome") {
		fmt.println("Something in the middle, mate.")
	}
}

		@(export) __update_symmap__:: proc() {

		}

		@(export) __apply_symmap__:: proc() {

		a = (cast(^string)__symmap__["a"])
	

		b = (cast(^string)__symmap__["b"])
	

		x = (cast(^int)__symmap__["x"])
	

		k = (cast(^int)__symmap__["k"])
	

		my_integer_variable = (cast(^int)__symmap__["my_integer_variable"])
	

		some_string = (cast(^string)__symmap__["some_string"])
	

		cond = (cast(^bool)__symmap__["cond"])
	

		cond1 = (cast(^bool)__symmap__["cond1"])
	

		cond2 = (cast(^bool)__symmap__["cond2"])
	

		odds = (cast(^[]int)__symmap__["odds"])
	

		h = (cast(^int)__symmap__["h"])
	

		y = (cast(^int)__symmap__["y"])
	

		z = (cast(^f64)__symmap__["z"])
	

		i = (cast(^int)__symmap__["i"])
	

		implicit_context_system = auto_cast __symmap__["implicit_context_system"]

		partial_switch = auto_cast __symmap__["partial_switch"]

		map_type = auto_cast __symmap__["map_type"]

		sum = auto_cast __symmap__["sum"]

		implicit_selector_expression = auto_cast __symmap__["implicit_selector_expression"]

		one_step = auto_cast __symmap__["one_step"]

		beyond = auto_cast __symmap__["beyond"]

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
