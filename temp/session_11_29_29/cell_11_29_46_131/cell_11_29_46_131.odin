

		package cell_11_29_46_131

		import "shared:jodin"
		import "core:io"
		import "core:os"
		import "core:sync"


		@(export) __cell__: ^jodin.Cell = nil
		__data_mutex__: ^sync.Ticket_Mutex = nil
		__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
		__symmap__: ^map[string]rawptr = nil

			sum : proc(nums: ..int, init_value:= 0) -> (result: int) = nil

			@(export) where_clauses :: proc() {
	fmt.println("\n#procedure 'where' clauses")

	{ // Sanity checks
		simple_sanity_check :: proc(x: [2]int)
			where len(x) > 1,
				  type_of(x) == [2]int {
			fmt.println(x)
		}
	}
	{ // Parametric polymorphism checks
		cross_2d :: proc(a, b: $T/[2]$E) -> E
			where intrinsics.type_is_numeric(E) {
			return a.x*b.y - a.y*b.x
		}
		cross_3d :: proc(a, b: $T/[3]$E) -> T
			where intrinsics.type_is_numeric(E) {
			x := a.y*b.z - a.z*b.y
			y := a.z*b.x - a.x*b.z
			z := a.x*b.y - a.y*b.z
			return T{x, y, z}
		}

		a := [2]int{1, 2}
		b := [2]int{5, -3}
		fmt.println(cross_2d(a, b))

		x := [3]f32{1, 4, 9}
		y := [3]f32{-5, 0, 3}
		fmt.println(cross_3d(x, y))

		// Failure case
		// i := [2]bool{true, false}
		// j := [2]bool{false, true}
		// fmt.println(cross_2d(i, j))

	}

	{ // Procedure groups usage
		foo :: proc(x: [$N]int) -> bool
			where N > 2 {
			fmt.println(#procedure, "was called with the parameter", x)
			return true
		}

		bar :: proc(x: [$N]int) -> bool
			where 0 < N,
				  N <= 2 {
			fmt.println(#procedure, "was called with the parameter", x)
			return false
		}

		baz :: proc{foo, bar}

		x := [3]int{1, 2, 3}
		y := [2]int{4, 9}
		ok_x := baz(x)
		ok_y := baz(y)
		assert(ok_x == true)
		assert(ok_y == false)
	}

	{ // Record types
		Foo :: struct($T: typeid, $N: int)
			where intrinsics.type_is_integer(T),
				  N > 2 {
			x: [N]T,
			y: [N-2]T,
		}

		T :: i32
		N :: 5
		f: Foo(T, N)
		#assert(size_of(f) == (N+N-2)*size_of(T))
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
