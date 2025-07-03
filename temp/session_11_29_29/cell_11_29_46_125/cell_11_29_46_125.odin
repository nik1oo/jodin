

		package cell_11_29_46_125

		import "shared:jodin"
		import "core:io"
		import "core:os"
		import "core:sync"


		@(export) __cell__: ^jodin.Cell = nil
		__data_mutex__: ^sync.Ticket_Mutex = nil
		__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
		__symmap__: ^map[string]rawptr = nil

			sum : proc(nums: ..int, init_value:= 0) -> (result: int) = nil

			@(export) reflection :: proc() {
	fmt.println("\n# reflection")

	Foo :: struct {
		x: int    `tag1`,
		y: string `json:"y_field"`,
		z: bool, // no tag
	}

	id := typeid_of(Foo)
	names := reflect.struct_field_names(id)
	types := reflect.struct_field_types(id)
	tags  := reflect.struct_field_tags(id)

	assert(len(names) == len(types) && len(names) == len(tags))

	fmt.println("Foo :: struct {")
	for tag, i in tags {
		name, type := names[i], types[i]
		if tag != "" {
			fmt.printf("\t%s: %T `%s`,\n", name, type, tag)
		} else {
			fmt.printf("\t%s: %T,\n", name, type)
		}
	}
	fmt.println("}")


	for tag, i in tags {
		if val, ok := reflect.struct_tag_lookup(tag, "json"); ok {
			fmt.printf("json: %s -> %s\n", names[i], val)
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
