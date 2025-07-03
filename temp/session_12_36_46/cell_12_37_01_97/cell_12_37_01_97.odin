

		package cell_12_37_01_97

		import "shared:jodin"
		import "core:io"
		import "core:os"
		import "core:sync"


		@(export) __cell__: ^jodin.Cell = nil
		__data_mutex__: ^sync.Ticket_Mutex = nil
		__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
		__symmap__: ^map[string]rawptr = nil

			sum : proc(nums: ..int, init_value:= 0) -> (result: int) = nil

			@(export) explicit_procedure_overloading :: proc() {
	fmt.println("\n# explicit procedure overloading")

	add_ints :: proc(a, b: int) -> int {
		x := a + b
		fmt.println("add_ints", x)
		return x
	}
	add_floats :: proc(a, b: f32) -> f32 {
		x := a + b
		fmt.println("add_floats", x)
		return x
	}
	add_numbers :: proc(a: int, b: f32, c: u8) -> int {
		x := int(a) + int(b) + int(c)
		fmt.println("add_numbers", x)
		return x
	}

	add :: proc{add_ints, add_floats, add_numbers}

	add(int(1), int(2))
	add(f32(1), f32(2))
	add(int(1), f32(2), u8(3))

	add(1, 2)     // untyped ints coerce to int tighter than f32
	add(1.0, 2.0) // untyped floats coerce to f32 tighter than int
	add(1, 2, 3)  // three parameters

	// Ambiguous answers
	// add(1.0, 2)
	// add(1, 2.0)
}

		@(export) __update_symmap__:: proc() {

		}

		@(export) __apply_symmap__:: proc() {

		sum = auto_cast __symmap__["sum"]

		}



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
