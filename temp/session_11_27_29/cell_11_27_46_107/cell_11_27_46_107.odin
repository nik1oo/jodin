

		package cell_11_27_46_107

		import "shared:jodin"
		import "core:io"
		import "core:os"
		import "core:sync"


		@(export) __cell__: ^jodin.Cell = nil
		__data_mutex__: ^sync.Ticket_Mutex = nil
		__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
		__symmap__: ^map[string]rawptr = nil

			sum : proc(nums: ..int, init_value:= 0) -> (result: int) = nil

			@(export) parametric_polymorphism :: proc() {
	fmt.println("\n# parametric polymorphism")

	print_value :: proc(value: $T) {
		fmt.printf("print_value: %T %v\n", value, value)
	}

	v1: int    = 1
	v2: f32    = 2.1
	v3: f64    = 3.14
	v4: string = "message"

	print_value(v1)
	print_value(v2)
	print_value(v3)
	print_value(v4)

	fmt.println()

	add :: proc(p, q: $T) -> T {
		x: T = p + q
		return x
	}

	a := add(3, 4)
	fmt.printf("a: %T = %v\n", a, a)

	b := add(3.2, 4.3)
	fmt.printf("b: %T = %v\n", b, b)

	// This is how `new` is implemented
	alloc_type :: proc($T: typeid) -> ^T {
		t := cast(^T)mem.alloc(size_of(T), align_of(T))
		t^ = T{} // Use default initialization value
		return t
	}

	copy_slice :: proc(dst, src: []$T) -> int {
		n := min(len(dst), len(src))
		if n > 0 {
			mem.copy(&dst[0], &src[0], n*size_of(T))
		}
		return n
	}

	double_params :: proc(a: $A, b: $B) -> A {
		return a + A(b)
	}

	fmt.println(double_params(12, 1.345))



	{ // Polymorphic Types and Type Specialization
		Table_Slot :: struct($Key, $Value: typeid) {
			occupied: bool,
			hash:     u32,
			key:      Key,
			value:    Value,
		}
		TABLE_SIZE_MIN :: 32
		Table :: struct($Key, $Value: typeid) {
			count:     int,
			allocator: mem.Allocator,
			slots:     []Table_Slot(Key, Value),
		}

		// Only allow types that are specializations of a (polymorphic) slice
		make_slice :: proc($T: typeid/[]$E, len: int) -> T {
			return make(T, len)
		}

		// Only allow types that are specializations of `Table`
		allocate :: proc(table: ^$T/Table, capacity: int) {
			c := context
			if table.allocator.procedure != nil {
				c.allocator = table.allocator
			}
			context = c

			table.slots = make_slice(type_of(table.slots), max(capacity, TABLE_SIZE_MIN))
		}

		expand :: proc(table: ^$T/Table) {
			c := context
			if table.allocator.procedure != nil {
				c.allocator = table.allocator
			}
			context = c

			old_slots := table.slots
			defer delete(old_slots)

			cap := max(2*len(table.slots), TABLE_SIZE_MIN)
			allocate(table, cap)

			for s in old_slots {
				if s.occupied {
					put(table, s.key, s.value)
				}
			}
		}

		// Polymorphic determination of a polymorphic struct
		// put :: proc(table: ^$T/Table, key: T.Key, value: T.Value) {
		put :: proc(table: ^Table($Key, $Value), key: Key, value: Value) {
			hash := get_hash(key) // Ad-hoc method which would fail in a different scope
			index := find_index(table, key, hash)
			if index < 0 {
				if f64(table.count) >= 0.75*f64(len(table.slots)) {
					expand(table)
				}
				assert(table.count <= len(table.slots))

				index = int(hash % u32(len(table.slots)))

				for table.slots[index].occupied {
					if index += 1; index >= len(table.slots) {
						index = 0
					}
				}

				table.count += 1
			}

			slot := &table.slots[index]
			slot.occupied = true
			slot.hash     = hash
			slot.key      = key
			slot.value    = value
		}


		// find :: proc(table: ^$T/Table, key: T.Key) -> (T.Value, bool) {
		find :: proc(table: ^Table($Key, $Value), key: Key) -> (Value, bool) {
			hash := get_hash(key)
			index := find_index(table, key, hash)
			if index < 0 {
				return Value{}, false
			}
			return table.slots[index].value, true
		}

		find_index :: proc(table: ^Table($Key, $Value), key: Key, hash: u32) -> int {
			if len(table.slots) <= 0 {
				return -1
			}

			index := int(hash % u32(len(table.slots)))
			for table.slots[index].occupied {
				if table.slots[index].hash == hash {
					if table.slots[index].key == key {
						return index
					}
				}

				if index += 1; index >= len(table.slots) {
					index = 0
				}
			}

			return -1
		}

		get_hash :: proc(s: string) -> u32 { // fnv32a
			h: u32 = 0x811c9dc5
			for i in 0..<len(s) {
				h = (h ~ u32(s[i])) * 0x01000193
			}
			return h
		}


		table: Table(string, int)

		for i in 0..=36 { put(&table, "Hellope", i) }
		for i in 0..=42 { put(&table, "World!",  i) }

		found, _ := find(&table, "Hellope")
		fmt.printf("`found` is %v\n", found)

		found, _ = find(&table, "World!")
		fmt.printf("`found` is %v\n", found)

		// I would not personally design a hash table like this in production
		// but this is a nice basic example
		// A better approach would either use a `u64` or equivalent for the key
		// and let the user specify the hashing function or make the user store
		// the hashing procedure with the table
	}

	{ // Parametric polymorphic union
		Error :: enum {
			Foo0,
			Foo1,
			Foo2,
			Foo3,
		}
		Para_Union :: union($T: typeid) {T, Error}
		r: Para_Union(int)
		fmt.println(typeid_of(type_of(r)))

		fmt.println(r)
		r = 123
		fmt.println(r)
		r = Error.Foo0 // r = .Foo0 is allow too, see implicit selector expressions below
		fmt.println(r)
	}

	{ // Polymorphic names
		foo :: proc($N: $I, $T: typeid) -> (res: [N]T) {
			// `N` is the constant value passed
			// `I` is the type of N
			// `T` is the type passed
			fmt.printf("Generating an array of type %v from the value %v of type %v\n",
					   typeid_of(type_of(res)), N, typeid_of(I))
			for i in 0..<N {
				res[i] = T(i*i)
			}
			return
		}

		T :: int
		array := foo(4, T)
		for v, i in array {
			assert(v == T(i*i))
		}

		// Matrix multiplication
		mul :: proc(a: [$M][$N]$T, b: [N][$P]T) -> (c: [M][P]T) {
			for i in 0..<M {
				for j in 0..<P {
					for k in 0..<N {
						c[i][j] += a[i][k] * b[k][j]
					}
				}
			}
			return
		}

		x := [2][3]f32{
			{1, 2, 3},
			{3, 2, 1},
		}
		y := [3][2]f32{
			{0, 8},
			{6, 2},
			{8, 4},
		}
		z := mul(x, y)
		assert(z == {{36, 24}, {20, 32}})
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
