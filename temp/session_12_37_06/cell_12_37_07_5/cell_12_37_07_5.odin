

		package cell_12_37_07_5

		import "shared:jodin"
		import "core:io"
		import "core:os"
		import "core:sync"

		import "core:fmt"

		@(export) __cell__: ^jodin.Cell = nil
		__data_mutex__: ^sync.Ticket_Mutex = nil
		__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
		__symmap__: ^map[string]rawptr = nil

			small_jupyter: ^[]u8

			small_odin: ^[]u8

			tiny_odin: ^[]u8
ole_gray_beard: []u8

		@(export) __update_symmap__:: proc() {

		__symmap__["ole_gray_beard"] = auto_cast &ole_gray_beard

		}

		@(export) __apply_symmap__:: proc() {

		small_jupyter = (cast(^[]u8)__symmap__["small_jupyter"])
	

		small_odin = (cast(^[]u8)__symmap__["small_odin"])
	

		tiny_odin = (cast(^[]u8)__symmap__["tiny_odin"])
	

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
	 ole_gray_beard, _ = os.read_entire_file_from_filename_or_err(`C:\Code\jodin\examples\ole-gray-beard.aac`)
	 jodin.display_audio(data=ole_gray_beard, format=jodin.Audio_Format.AAC)


			os.stdout = __original_stdout__
			os.stderr = __original_stderr__
		}
