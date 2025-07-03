

		package cell_12_28_49_149

		import "shared:jodin"
		import "core:io"
		import "core:os"
		import "core:sync"


		@(export) __cell__: ^jodin.Cell = nil
		__data_mutex__: ^sync.Ticket_Mutex = nil
		__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
		__symmap__: ^map[string]rawptr = nil

			sum : proc(nums: ..int, init_value:= 0) -> (result: int) = nil

			@(export) or_else_operator :: proc() {
	fmt.println("\n#'or_else'")
	{
		m: map[string]int
		i: int
		ok: bool

		if i, ok = m["hellope"]; !ok {
			i = 123
		}
		// The above can be mapped to 'or_else'
		i = m["hellope"] or_else 123

		assert(i == 123)
	}
	{
		// 'or_else' can be used with type assertions too, as they
		// have optional ok semantics
		v: union{int, f64}
		i: int
		i = v.(int) or_else 123
		i = v.? or_else 123 // Type inference magic
		assert(i == 123)

		m: Maybe(int)
		i = m.? or_else 456
		assert(i == 456)
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
