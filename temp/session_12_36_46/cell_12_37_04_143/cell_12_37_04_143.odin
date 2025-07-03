

		package cell_12_37_04_143

		import "shared:jodin"
		import "core:io"
		import "core:os"
		import "core:sync"


		@(export) __cell__: ^jodin.Cell = nil
		__data_mutex__: ^sync.Ticket_Mutex = nil
		__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
		__symmap__: ^map[string]rawptr = nil

			sum : proc(nums: ..int, init_value:= 0) -> (result: int) = nil

			@(export) constant_literal_expressions :: proc() {
	fmt.println("\n#constant literal expressions")

	Bar :: struct {x, y: f32}
	Foo :: struct {a, b: int, using c: Bar}

	FOO_CONST :: Foo{b = 2, a = 1, c = {3, 4}}


	fmt.println(FOO_CONST.a)
	fmt.println(FOO_CONST.b)
	fmt.println(FOO_CONST.c)
	fmt.println(FOO_CONST.c.x)
	fmt.println(FOO_CONST.c.y)
	fmt.println(FOO_CONST.x) // using works as expected
	fmt.println(FOO_CONST.y)

	fmt.println("-------")

	ARRAY_CONST :: [3]int{1 = 4, 2 = 9, 0 = 1}

	fmt.println(ARRAY_CONST[0])
	fmt.println(ARRAY_CONST[1])
	fmt.println(ARRAY_CONST[2])

	fmt.println("-------")

	FOO_ARRAY_DEFAULTS :: [3]Foo{{}, {}, {}}
	fmt.println(FOO_ARRAY_DEFAULTS[2].x)

	fmt.println("-------")

	Baz :: enum{A=5, B, C, D}
	ENUM_ARRAY_CONST :: [Baz]int{.A ..= .C = 1, .D = 16}

	fmt.println(ENUM_ARRAY_CONST[.A])
	fmt.println(ENUM_ARRAY_CONST[.B])
	fmt.println(ENUM_ARRAY_CONST[.C])
	fmt.println(ENUM_ARRAY_CONST[.D])

	fmt.println("-------")

	Sparse_Baz :: enum{A=5, B, C, D=16}
	#assert(len(Sparse_Baz) < len(#sparse[Sparse_Baz]int))
	SPARSE_ENUM_ARRAY_CONST :: #sparse[Sparse_Baz]int{.A ..= .C = 1, .D = 16}

	fmt.println(SPARSE_ENUM_ARRAY_CONST[.A])
	fmt.println(SPARSE_ENUM_ARRAY_CONST[.B])
	fmt.println(SPARSE_ENUM_ARRAY_CONST[.C])
	fmt.println(SPARSE_ENUM_ARRAY_CONST[.D])

	fmt.println("-------")


	STRING_CONST :: "Hellope!"

	fmt.println(STRING_CONST[0])
	fmt.println(STRING_CONST[2])
	fmt.println(STRING_CONST[3])

	fmt.println(STRING_CONST[0:5])
	fmt.println(STRING_CONST[3:][:4])
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
