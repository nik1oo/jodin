

		package cell_11_27_49_145

		import "shared:jodin"
		import "core:io"
		import "core:os"
		import "core:sync"


		@(export) __cell__: ^jodin.Cell = nil
		__data_mutex__: ^sync.Ticket_Mutex = nil
		__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
		__symmap__: ^map[string]rawptr = nil

			sum : proc(nums: ..int, init_value:= 0) -> (result: int) = nil

			@(export) union_maybe :: proc() {
	fmt.println("\n#union based maybe")

	// NOTE: This is already built-in, and this is just a reimplementation to explain the behaviour
	Maybe :: union($T: typeid) {T}

	i: Maybe(u8)
	p: Maybe(^u8) // No tag is stored for pointers, nil is the sentinel value

	// Tag size will be as small as needed for the number of variants
	#assert(size_of(i) == size_of(u8) + size_of(u8))
	// No need to store a tag here, the `nil` state is shared with the variant's `nil`
	#assert(size_of(p) == size_of(^u8))

	i = 123
	x := i.?
	y, y_ok := p.?
	p = &x
	z, z_ok := p.?

	fmt.println(i, p)
	fmt.println(x, &x)
	fmt.println(y, y_ok)
	fmt.println(z, z_ok)
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
