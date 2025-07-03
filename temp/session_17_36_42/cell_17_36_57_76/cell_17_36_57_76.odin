

		package cell_17_36_57_76

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

			some_string: ^string

			my_integer_variable: ^int

			x: ^int

			h: ^int

			k: ^int

			i: ^int

			y: ^int

			z: ^f64
cond: bool
cond1: bool
cond2: bool

			one_angry_dwarf : proc() -> int = nil

			@(export) one_step :: proc() { fmt.println("one_step") }

			@(export) beyond :: proc() { fmt.println("beyond") }

		@(export) __update_symmap__:: proc() {

		__symmap__["cond"] = auto_cast &cond

		__symmap__["cond1"] = auto_cast &cond1

		__symmap__["cond2"] = auto_cast &cond2

		}

		@(export) __apply_symmap__:: proc() {

		a = (cast(^string)__symmap__["a"])
	

		b = (cast(^string)__symmap__["b"])
	

		some_string = (cast(^string)__symmap__["some_string"])
	

		my_integer_variable = (cast(^int)__symmap__["my_integer_variable"])
	

		x = (cast(^int)__symmap__["x"])
	

		h = (cast(^int)__symmap__["h"])
	

		k = (cast(^int)__symmap__["k"])
	

		i = (cast(^int)__symmap__["i"])
	

		y = (cast(^int)__symmap__["y"])
	

		z = (cast(^f64)__symmap__["z"])
	

		one_angry_dwarf = auto_cast __symmap__["one_angry_dwarf"]

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
	cond = true
	cond1 = true
	cond2 = false


			os.stdout = __original_stdout__
			os.stderr = __original_stderr__
		}
