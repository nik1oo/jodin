

		package cell_14_31_25_129

		import "shared:jodin"
		import "core:io"
		import "core:os"
		import "core:sync"

		@(export) __cell__: ^jodin.Cell = nil
		__data_mutex__: ^sync.Ticket_Mutex = nil
		__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
		__symmap__: ^map[string]rawptr = nil

			@(export) unroll_for_statement :: proc() {
	fmt.println("\n#'#unroll for' statements")

	// '#unroll for' works the same as if the 'inline' prefix did not
	// exist but these ranged loops are explicitly unrolled which can
	// be very very useful for certain optimizations

	fmt.println("Ranges")
	#unroll for x, i in 1..<4 {
		fmt.println(x, i)
	}

	fmt.println("Strings")
	#unroll for r, i in "Hello, 世界" {
		fmt.println(r, i)
	}

	fmt.println("Arrays")
	#unroll for elem, idx in ([4]int{1, 4, 9, 16}) {
		fmt.println(elem, idx)
	}


	Foo_Enum :: enum {
		A = 1,
		B,
		C = 6,
		D,
	}
	fmt.println("Enum types")
	#unroll for elem, idx in Foo_Enum {
		fmt.println(elem, idx)
	}
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