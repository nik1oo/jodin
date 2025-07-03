

		package cell_12_28_48_139

		import "shared:jodin"
		import "core:io"
		import "core:os"
		import "core:sync"


		@(export) __cell__: ^jodin.Cell = nil
		__data_mutex__: ^sync.Ticket_Mutex = nil
		__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
		__symmap__: ^map[string]rawptr = nil

			sum : proc(nums: ..int, init_value:= 0) -> (result: int) = nil

			@(export) range_statements_with_multiple_return_values :: proc() {
	fmt.println("\n#range statements with multiple return values")
	My_Iterator :: struct {
		index: int,
		data:  []i32,
	}
	make_my_iterator :: proc(data: []i32) -> My_Iterator {
		return My_Iterator{data = data}
	}
	my_iterator :: proc(it: ^My_Iterator) -> (val: i32, idx: int, cond: bool) {
		if cond = it.index < len(it.data); cond {
			val = it.data[it.index]
			idx = it.index
			it.index += 1
		}
		return
	}

	data := make([]i32, 6)
	for _, i in data {
		data[i] = i32(i*i)
	}

	{ // Manual Style
		it := make_my_iterator(data)
		for {
			val, _, cond := my_iterator(&it)
			if !cond {
				break
			}
			fmt.println(val)
		}
	}
	{ // or_break
		it := make_my_iterator(data)
		loop: for {
			val, _ := my_iterator(&it) or_break loop
			fmt.println(val)
		}
	}
	{ // first value
		it := make_my_iterator(data)
		for val in my_iterator(&it) {
			fmt.println(val)
		}
	}
	{ // first and second value
		it := make_my_iterator(data)
		for val, idx in my_iterator(&it) {
			fmt.println(val, idx)
		}
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
