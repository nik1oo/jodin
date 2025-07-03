

		package cell_11_27_45_103

		import "shared:jodin"
		import "core:io"
		import "core:os"
		import "core:sync"


		@(export) __cell__: ^jodin.Cell = nil
		__data_mutex__: ^sync.Ticket_Mutex = nil
		__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
		__symmap__: ^map[string]rawptr = nil

			sum : proc(nums: ..int, init_value:= 0) -> (result: int) = nil

			@(export) using_statement :: proc() {
	fmt.println("\n# using statement")
	// using can used to bring entities declared in a scope/namespace
	// into the current scope. This can be applied to import names, struct
	// fields, procedure fields, and struct values.

	Vector3 :: struct{x, y, z: f32}
	{
		Entity :: struct {
			position: Vector3,
			orientation: quaternion128,
		}

		// It can used like this:
		foo0 :: proc(entity: ^Entity) {
			fmt.println(entity.position.x, entity.position.y, entity.position.z)
		}

		// The entity members can be brought into the procedure scope by using it:
		foo1 :: proc(entity: ^Entity) {
			using entity
			fmt.println(position.x, position.y, position.z)
		}

		// The using can be applied to the parameter directly:
		foo2 :: proc(using entity: ^Entity) {
			fmt.println(position.x, position.y, position.z)
		}

		// It can also be applied to sub-fields:
		foo3 :: proc(entity: ^Entity) {
			using entity.position
			fmt.println(x, y, z)
		}
	}
	{
		// We can also apply the using statement to the struct fields directly,
		// making all the fields of position appear as if they on Entity itself:
		Entity :: struct {
			using position: Vector3,
			orientation: quaternion128,
		}
		foo :: proc(entity: ^Entity) {
			fmt.println(entity.x, entity.y, entity.z)
		}


		// Subtype polymorphism
		// It is possible to get subtype polymorphism, similar to inheritance-like
		// functionality in C++, but without the requirement of vtables or unknown
		// struct layout:

		Colour :: struct {r, g, b, a: u8}
		Frog :: struct {
			ribbit_volume: f32,
			using entity: Entity,
			colour: Colour,
		}

		frog: Frog
		// Both work
		foo(&frog.entity)
		foo(&frog)
		frog.x = 123

		// Note: using can be applied to arbitrarily many things, which allows
		// the ability to have multiple subtype polymorphism (but also its issues).

		// Note: using’d fields can still be referred by name.
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
