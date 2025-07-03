

		package cell_12_28_39_48

		import "shared:jodin"
		import "core:io"
		import "core:os"
		import "core:sync"


		@(export) __cell__: ^jodin.Cell = nil
		__data_mutex__: ^sync.Ticket_Mutex = nil
		__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
		__symmap__: ^map[string]rawptr = nil

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

				for character, index in some_string {
    fmt.println(index, character)
}

				for value, index in some_array {
    fmt.println(index, value)
}

				for value, index in some_slice {
    fmt.println(index, value)
}

				for value, index in some_dynamic_array {
    fmt.println(index, value)
}

				for key, value in some_map {
    fmt.println(key, value)
}


			os.stdout = __original_stdout__
			os.stderr = __original_stderr__
		}
