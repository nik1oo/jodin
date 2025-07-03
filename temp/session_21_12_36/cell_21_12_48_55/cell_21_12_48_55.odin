

		package cell_21_12_48_55

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

			y: ^int

			z: ^f64

			my_integer_variable: ^int

			i: ^int

			h: ^int

			x: ^int

			k: ^int

			a: ^string

			b: ^string

			some_string: ^string

		@(export) __update_symmap__:: proc() {

		}

		@(export) __apply_symmap__:: proc() {

		y = (cast(^int)__symmap__["y"])
	

		z = (cast(^f64)__symmap__["z"])
	

		my_integer_variable = (cast(^int)__symmap__["my_integer_variable"])
	

		i = (cast(^int)__symmap__["i"])
	

		h = (cast(^int)__symmap__["h"])
	

		x = (cast(^int)__symmap__["x"])
	

		k = (cast(^int)__symmap__["k"])
	

		a = (cast(^string)__symmap__["a"])
	

		b = (cast(^string)__symmap__["b"])
	

		some_string = (cast(^string)__symmap__["some_string"])
	

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
	 #partial switch arch := ODIN_ARCH; arch {
case .i386:
    fmt.println("32-bit")
case .amd64:
    fmt.println("64-bit")
case: // default
    fmt.println("Unsupported architecture")
}


			os.stdout = __original_stdout__
			os.stderr = __original_stderr__
		}
