

		package cell_11_27_48_135

		import "shared:jodin"
		import "core:io"
		import "core:os"
		import "core:sync"


		@(export) __cell__: ^jodin.Cell = nil
		__data_mutex__: ^sync.Ticket_Mutex = nil
		__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
		__symmap__: ^map[string]rawptr = nil

			sum : proc(nums: ..int, init_value:= 0) -> (result: int) = nil

			@(export) ranged_fields_for_array_compound_literals :: proc() {
	fmt.println("\n#ranged fields for array compound literals")
	{ // Normal Array Literal
		foo := [?]int{1, 4, 9, 16}
		fmt.println(foo)
	}
	{ // Indexed
		foo := [?]int{
			3 = 16,
			1 = 4,
			2 = 9,
			0 = 1,
		}
		fmt.println(foo)
	}
	{ // Ranges
		i := 2
		foo := [?]int {
			0 = 123,
			5..=9 = 54,
			10..<16 = i*3 + (i-1)*2,
		}
		#assert(len(foo) == 16)
		fmt.println(foo) // [123, 0, 0, 0, 0, 54, 54, 54, 54, 54, 8, 8, 8, 8, 8]
	}
	{ // Slice and Dynamic Array support
		i := 2
		foo_slice := []int {
			0 = 123,
			5..=9 = 54,
			10..<16 = i*3 + (i-1)*2,
		}
		assert(len(foo_slice) == 16)
		fmt.println(foo_slice) // [123, 0, 0, 0, 0, 54, 54, 54, 54, 54, 8, 8, 8, 8, 8]

		foo_dynamic_array := [dynamic]int {
			0 = 123,
			5..=9 = 54,
			10..<16 = i*3 + (i-1)*2,
		}
		assert(len(foo_dynamic_array) == 16)
		fmt.println(foo_dynamic_array) // [123, 0, 0, 0, 0, 54, 54, 54, 54, 54, 8, 8, 8, 8, 8]
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
