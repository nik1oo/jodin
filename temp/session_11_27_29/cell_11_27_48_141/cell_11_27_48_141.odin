

		package cell_11_27_48_141

		import "shared:jodin"
		import "core:io"
		import "core:os"
		import "core:sync"


		@(export) __cell__: ^jodin.Cell = nil
		__data_mutex__: ^sync.Ticket_Mutex = nil
		__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
		__symmap__: ^map[string]rawptr = nil

			sum : proc(nums: ..int, init_value:= 0) -> (result: int) = nil

			@(export) soa_struct_layout :: proc() {
	fmt.println("\n#SOA Struct Layout")

	{
		Vector3 :: struct {x, y, z: f32}

		N :: 2
		v_aos: [N]Vector3
		v_aos[0].x = 1
		v_aos[0].y = 4
		v_aos[0].z = 9

		fmt.println(len(v_aos))
		fmt.println(v_aos[0])
		fmt.println(v_aos[0].x)
		fmt.println(&v_aos[0].x)

		v_aos[1] = {0, 3, 4}
		v_aos[1].x = 2
		fmt.println(v_aos[1])
		fmt.println(v_aos)

		v_soa: #soa[N]Vector3

		v_soa[0].x = 1
		v_soa[0].y = 4
		v_soa[0].z = 9


		// Same syntax as AOS and treat as if it was an array
		fmt.println(len(v_soa))
		fmt.println(v_soa[0])
		fmt.println(v_soa[0].x)
		fmt.println(&v_soa[0].x)
		v_soa[1] = {0, 3, 4}
		v_soa[1].x = 2
		fmt.println(v_soa[1])

		// Can use SOA syntax if necessary
		v_soa.x[0] = 1
		v_soa.y[0] = 4
		v_soa.z[0] = 9
		fmt.println(v_soa.x[0])

		// Same pointer addresses with both syntaxes
		assert(&v_soa[0].x == &v_soa.x[0])


		// Same fmt printing
		fmt.println(v_aos)
		fmt.println(v_soa)
	}
	{
		// Works with arrays of length <= 4 which have the implicit fields xyzw/rgba
		Vector3 :: distinct [3]f32

		N :: 2
		v_aos: [N]Vector3
		v_aos[0].x = 1
		v_aos[0].y = 4
		v_aos[0].z = 9

		v_soa: #soa[N]Vector3

		v_soa[0].x = 1
		v_soa[0].y = 4
		v_soa[0].z = 9
	}
	{
		// SOA Slices
		// Vector3 :: struct {x, y, z: f32}
		Vector3 :: struct {x: i8, y: i16, z: f32}

		N :: 3
		v: #soa[N]Vector3
		v[0].x = 1
		v[0].y = 4
		v[0].z = 9

		s: #soa[]Vector3
		s = v[:]
		assert(len(s) == N)
		fmt.println(s)
		fmt.println(s[0].x)

		a := s[1:2]
		assert(len(a) == 1)
		fmt.println(a)

		d: #soa[dynamic]Vector3

		append_soa(&d, Vector3{1, 2, 3}, Vector3{4, 5, 9}, Vector3{-4, -4, 3})
		fmt.println(d)
		fmt.println(len(d))
		fmt.println(cap(d))
		fmt.println(d[:])
	}
	{ // soa_zip and soa_unzip
		fmt.println("\nsoa_zip and soa_unzip")

		x := []i32{1, 3, 9}
		y := []f32{2, 4, 16}
		z := []b32{true, false, true}

		// produce an #soa slice the normal slices passed
		s := soa_zip(a=x, b=y, c=z)

		// iterate over the #soa slice
		for v, i in s {
			fmt.println(v, i) // exactly the same as s[i]
			// NOTE: 'v' is NOT a temporary value but has a specialized addressing mode
			// which means that when accessing v.a etc, it does the correct transformation
			// internally:
			//         s[i].a === s.a[i]
			fmt.println(v.a, v.b, v.c)
		}

		// Recover the slices from the #soa slice
		a, b, c := soa_unzip(s)
		fmt.println(a, b, c)
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
