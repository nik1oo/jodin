

		package cell_12_37_03_121

		import "shared:jodin"
		import "core:io"
		import "core:os"
		import "core:sync"


		@(export) __cell__: ^jodin.Cell = nil
		__data_mutex__: ^sync.Ticket_Mutex = nil
		__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
		__symmap__: ^map[string]rawptr = nil

			sum : proc(nums: ..int, init_value:= 0) -> (result: int) = nil

			@(export) bit_set_type :: proc() {
	fmt.println("\n# bit_set type")

	{
		Day :: enum {
			Sunday,
			Monday,
			Tuesday,
			Wednesday,
			Thursday,
			Friday,
			Saturday,
		}

		Days :: distinct bit_set[Day]
		WEEKEND :: Days{.Sunday, .Saturday}

		d: Days
		d = {.Sunday, .Monday}
		e := d + WEEKEND
		e += {.Monday}
		fmt.println(d, e)

		ok := .Saturday in e // `in` is only allowed for `map` and `bit_set` types
		fmt.println(ok)
		if .Saturday in e {
			fmt.println("Saturday in", e)
		}
		X :: .Saturday in WEEKEND // Constant evaluation
		fmt.println(X)
		fmt.println("Cardinality:", card(e))
	}
	{
		x: bit_set['A'..='Z']
		#assert(size_of(x) == size_of(u32))
		y: bit_set[0..=8; u16]
		fmt.println(typeid_of(type_of(x))) // bit_set[A..=Z]
		fmt.println(typeid_of(type_of(y))) // bit_set[0..=8; u16]

		x += {'F'}
		assert('F' in x)
		x -= {'F'}
		assert('F' not_in x)

		y += {1, 4, 2}
		assert(2 in y)
	}
	{
		Letters :: bit_set['A'..='Z']
		a := Letters{'A', 'B'}
		b := Letters{'A', 'B', 'C', 'D', 'F'}
		c := Letters{'A', 'B'}

		assert(a <= b) // 'a' is a subset of 'b'
		assert(b >= a) // 'b' is a superset of 'a'
		assert(a < b)  // 'a' is a strict subset of 'b'
		assert(b > a)  // 'b' is a strict superset of 'a'

		assert(!(a < c)) // 'a' is a not strict subset of 'c'
		assert(!(c > a)) // 'c' is a not strict superset of 'a'
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
