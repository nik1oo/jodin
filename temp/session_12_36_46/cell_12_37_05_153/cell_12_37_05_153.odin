

		package cell_12_37_05_153

		import "shared:jodin"
		import "core:io"
		import "core:os"
		import "core:sync"


		@(export) __cell__: ^jodin.Cell = nil
		__data_mutex__: ^sync.Ticket_Mutex = nil
		__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
		__symmap__: ^map[string]rawptr = nil

			sum : proc(nums: ..int, init_value:= 0) -> (result: int) = nil

			@(export) or_break_and_or_continue_operators :: proc() {
	fmt.println("\n#'or_break' and 'or_continue'")
	// The concept of 'or_break' and 'or_continue' is very similar to that of 'or_return'.
	// The difference is that unlike 'or_return', the value does not get returned from
	// the current procedure but rather discarded if it is 'false' or not 'nil', and then
	// the specified branch (i.e. break or continue).
	// The or branch expression can be labelled if a specific statement needs to be used.

	Error :: enum {
		None,
		Something_Bad,
		Something_Worse,
		The_Worst,
		Your_Mum,
	}

	caller_1 :: proc() -> Error {
		return .Something_Bad
	}

	caller_2 :: proc() -> (int, Error) {
		return 123, .Something_Worse
	}
	caller_3 :: proc() -> (int, int, Error) {
		return 123, 345, .None
	}

	for { // common approach
		err := caller_1()
		if err != nil {
			break
		}
	}
	for { // or_break approach
		caller_1() or_break
	}

	for { // or_break approach with multiple values
		n := caller_2() or_break
		_ = n
	}

	loop: for { // or_break approach with named label
		n := caller_2() or_break loop
		_ = n
	}

	for { // or_continue
		x, y := caller_3() or_continue
		_, _ = x, y

		break
	}

	continue_loop: for { // or_continue with named label
		x, y := caller_3() or_continue continue_loop
		_, _ = x, y

		break
	}

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
