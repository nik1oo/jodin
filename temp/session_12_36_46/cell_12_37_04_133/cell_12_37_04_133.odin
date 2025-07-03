

		package cell_12_37_04_133

		import "shared:jodin"
		import "core:io"
		import "core:os"
		import "core:sync"


		@(export) __cell__: ^jodin.Cell = nil
		__data_mutex__: ^sync.Ticket_Mutex = nil
		__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
		__symmap__: ^map[string]rawptr = nil

			sum : proc(nums: ..int, init_value:= 0) -> (result: int) = nil

			@(export) foreign_system :: proc() {
	fmt.println("\n#foreign system")
	when ODIN_OS == .Windows {
		// It is sometimes necessarily to interface with foreign code,
		// such as a C library. In Odin, this is achieved through the
		// foreign system. You can “import” a library into the code
		// using the same semantics as a normal import declaration.

		// This foreign import declaration will create a
		// “foreign import name” which can then be used to associate
		// entities within a foreign block.

		foreign kernel32 {
			ExitProcess :: proc "stdcall" (exit_code: u32) ---
		}

		// Foreign procedure declarations have the cdecl/c calling
		// convention by default unless specified otherwise. Due to
		// foreign procedures do not have a body declared within this
		// code, you need append the --- symbol to the end to distinguish
		// it as a procedure literal without a body and not a procedure type.

		// The attributes system can be used to change specific properties
		// of entities declared within a block:

		@(default_calling_convention = "std")
		foreign kernel32 {
			@(link_name="GetLastError") get_last_error :: proc() -> i32 ---
		}

		// Example using the link_prefix attribute
		@(default_calling_convention = "std")
		@(link_prefix = "Get")
		foreign kernel32 {
			LastError :: proc() -> i32 ---
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
	 when ODIN_OS == .Windows {
	foreign import kernel32 "system:kernel32.lib"
}


			os.stdout = __original_stdout__
			os.stderr = __original_stderr__
		}
