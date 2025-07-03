

		package cell_12_37_06_159

		import "shared:jodin"
		import "core:io"
		import "core:os"
		import "core:sync"


		@(export) __cell__: ^jodin.Cell = nil
		__data_mutex__: ^sync.Ticket_Mutex = nil
		__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
		__symmap__: ^map[string]rawptr = nil

			sum : proc(nums: ..int, init_value:= 0) -> (result: int) = nil

			@(export) bit_field_type :: proc() {
	fmt.println("\n# bit_field type")
	// A `bit_field` is a record type in Odin that is akin to a bit-packed struct.
	// IMPORTNAT NOTE: `bit_field` is NOT equivalent to `bit_set` as it has different sematics and use cases.

	{
		// `bit_field` fields are accessed by using a dot:
		Foo :: bit_field u16 {          // backing type must be an integer or array of integers
		    x: i32     | 3,             // signed integers will be signed extended on use
		    y: u16     | 2 + 3,         // general expressions
		    z: My_Enum | SOME_CONSTANT, // ability to define the bit-width elsewhere
		    w: bool    | 2 when SOME_CONSTANT > 10 else 1,
		}

		v := Foo{}
		v.x = 3 // truncates the value to fit into 3 bits
		fmt.println(v.x) // accessing will convert `v.x` to an `i32` and do an appropriate sign extension


		My_Enum :: enum u8 {A, B, C, D}
		SOME_CONSTANT :: 7
	}

	{
		// A `bit_field` is different from a struct in that you must specify the backing type.
		// This backing type must be an integer or a fixed-length array of integers.
		// This is useful if there needs to be a specific alignment or access pattern for the record.

		Bar :: bit_field u32   {}
		Baz :: bit_field [4]u8 {}
	}

	// IMPORTANT NOTES:
	//  * If _all_ of the fields in a bit_field are 1-bit in size and they are all booleans,
	//    please consider using a `bit_set` instead.
	//  * Odin's `bit_field` and C's bit-fields might not be compatible
	//     * Odin's `bit_field`s have a well defined layout (Least-Significant-Bit)
	//     * C's bit-fields on `struct`s are undefined and are not portable across targets and compilers
	//  * A `bit_field`'s field type can only be one of the following:
	//     * Integer
	//     * Boolean
	//     * Enum
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
