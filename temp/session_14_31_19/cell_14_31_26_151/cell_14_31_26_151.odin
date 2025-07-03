

		package cell_14_31_26_151

		import "shared:jodin"
		import "core:io"
		import "core:os"
		import "core:sync"

		@(export) __cell__: ^jodin.Cell = nil
		__data_mutex__: ^sync.Ticket_Mutex = nil
		__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
		__symmap__: ^map[string]rawptr = nil

			@(export) or_return_operator :: proc() {
	fmt.println("\n#'or_return'")
	// The concept of 'or_return' will work by popping off the end value in a multiple
	// valued expression and checking whether it was not 'nil' or 'false', and if so,
	// set the end return value to value if possible. If the procedure only has one
	// return value, it will do a simple return. If the procedure had multiple return
	// values, 'or_return' will require that all parameters be named so that the end
	// value could be assigned to by name and then an empty return could be called.

	Error :: enum {
		None,
		Something_Bad,
		Something_Worse,
		The_Worst,
		Your_Mum,
	}

	caller_1 :: proc() -> Error {
		return .None
	}

	caller_2 :: proc() -> (int, Error) {
		return 123, .None
	}
	caller_3 :: proc() -> (int, int, Error) {
		return 123, 345, .None
	}

	foo_1 :: proc() -> Error {
		// This can be a common idiom in many code bases
		n0, err := caller_2()
		if err != nil {
			return err
		}

		// The above idiom can be transformed into the following
		n1 := caller_2() or_return


		// And if the expression is 1-valued, it can be used like this
		caller_1() or_return
		// which is functionally equivalent to
		if err1 := caller_1(); err1 != nil {
			return err1
		}

		// Multiple return values still work with 'or_return' as it only
		// pops off the end value in the multi-valued expression
		n0, n1 = caller_3() or_return

		return .None
	}
	foo_2 :: proc() -> (n: int, err: Error) {
		// It is more common that your procedure returns multiple values
		// If 'or_return' is used within a procedure multiple parameters (2+),
		// then all the parameters must be named so that the remaining parameters
		// so that a bare 'return' statement can be used

		// This can be a common idiom in many code bases
		x: int
		x, err = caller_2()
		if err != nil {
			return
		}

		// The above idiom can be transformed into the following
		y := caller_2() or_return
		_ = y

		// And if the expression is 1-valued, it can be used like this
		caller_1() or_return

		// which is functionally equivalent to
		if err1 := caller_1(); err1 != nil {
			err = err1
			return
		}

		// If using a non-bare 'return' statement is required, setting the return values
		// using the normal idiom is a better choice and clearer to read.
		if z, zerr := caller_2(); zerr != nil {
			return -345 * z, zerr
		}

		defer if err != nil {
			fmt.println("Error in", #procedure, ":" , err)
		}

		n = 123
		return
	}

	foo_1()
	foo_2()
}

		@(export) __update_symmap__:: proc() {

		}

		@(export) __apply_symmap__:: proc() {

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
<><
><
			os.stdout = __original_stdout__
			os.stderr = __original_stderr__
		}
>