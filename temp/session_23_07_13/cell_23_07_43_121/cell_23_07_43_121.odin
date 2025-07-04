

		package cell_23_07_43_121

		import "shared:jodin"
		import "core:io"
		import "core:os"
		import "core:sync"














		import "core:fmt"
		import "core:mem"
		import "core:thread"
		import "core:time"
		import "core:reflect"
		import "base:runtime"
		import "base:intrinsics"
		import "core:math/big"


























		@(export) __cell__: ^jodin.Cell = nil
		__data_mutex__: ^sync.Ticket_Mutex = nil
		__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
		__symmap__: ^map[string]rawptr = nil

			cond: ^bool

			cond1: ^bool

			cond2: ^bool

			my_integer_variable: ^int

			i: ^int

			odds: ^[]int

			x: ^int

			y: ^int

			z: ^f64

			k: ^int

			some_string: ^string

			a: ^string

			b: ^string

			h: ^int

			one_step : proc() = nil

			beyond : proc() = nil

			partial_switch : proc() = nil

			map_type : proc() = nil

			implicit_context_system : proc() = nil

			one_angry_dwarf : proc() -> int = nil

			sum : proc(nums: ..int, init_value:= 0) -> (result: int) = nil

			implicit_selector_expression : proc() = nil

			@(export) bit_set_type :: proc() �o��         �o��         @p��  >                                                                                                                                                                                                                                                                                                                                                      
		fmt.println(ok)
		if .Saturday in e {
			fmt.println("Saturday in", e)
		}
		X :: .Saturday in WEEKEND // Constant evaluation
		fmt.println(X)
		fmt.println("Cardinality:", card(e))
	}
	{
		x^: bit_set['A'..='Z']
		#assert(size_of(x^) == size_of(u32))
		y^: bit_set[0..=8; u16]
		fmt.println(typeid_of(type_of(x^))) // bit_set[A..=Z]
		fmt.println(typeid_of(type_of(y^))) // bit_set[0..=8; u16]

		x^ += {'F'}
		assert('F' in x^)
		x^ -= {'F'}
		assert('F' not_in x^)

		y^ += {1, 4, 2}
		assert(2 in y^)
	}
	{
		Letters :: bit_set['A'..='Z']
		a^ := Letters{'A', 'B'}
		b^ := Letters{'A', 'B', 'C', 'D', 'F'}
		c := Letters{'A', 'B'}

		assert(a^ <= b^) // 'a' is a subset of 'b'
		assert(b^ >= a^) // 'b' is a superset of 'a'
		assert(a^ < b^)  // 'a' is a strict subset of 'b'
		assert(b^ > a^)  // 'b' is a strict superset of 'a'

		assert(!(a^ < c)) // 'a' is a not strict subset of 'c'
		assert(!(c > a^)) // 'c' is a not strict superset of 'a'
	}
}

		@(export) __update_symmap__:: proc() {

		}

		@(export) __apply_symmap__:: proc() {

		cond = (cast(^bool)__symmap__["cond"])
	

		cond1 = (cast(^bool)__symmap__["cond1"])
	

		cond2 = (cast(^bool)__symmap__["cond2"])
	

		my_integer_variable = (cast(^int)__symmap__["my_integer_variable"])
	

		i = (cast(^int)__symmap__["i"])
	

		odds = (cast(^[]int)__symmap__["odds"])
	

		x = (cast(^int)__symmap__["x"])
	

		y = (cast(^int)__symmap__["y"])
	

		z = (cast(^f64)__symmap__["z"])
	

		k = (cast(^int)__symmap__["k"])
	

		some_string = (cast(^string)__symmap__["some_string"])
	

		a = (cast(^string)__symmap__["a"])
	

		b = (cast(^string)__symmap__["b"])
	

		h = (cast(^int)__symmap__["h"])
	

		one_step = auto_cast __symmap__["one_step"]

		beyond = auto_cast __symmap__["beyond"]

		partial_switch = auto_cast __symmap__["partial_switch"]

		map_type = auto_cast __symmap__["map_type"]

		implicit_context_system = auto_cast __symmap__["implicit_context_system"]

		one_angry_dwarf = auto_cast __symmap__["one_angry_dwarf"]

		sum = auto_cast __symmap__["sum"]

		implicit_selector_expression = auto_cast __symmap__["implicit_selector_expression"]

		}









Y : int : 123
Z :: Y + 7










X :: "what"






















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
