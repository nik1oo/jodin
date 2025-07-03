

		package cell_11_27_51_3

		import "shared:jodin"
		import "core:io"
		import "core:os"
		import "core:sync"


		@(export) __cell__: ^jodin.Cell = nil
		__data_mutex__: ^sync.Ticket_Mutex = nil
		__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
		__symmap__: ^map[string]rawptr = nil
small_jupyter: []u8
small_odin: []u8
tiny_odin: []u8

		@(export) __update_symmap__:: proc() {

		__symmap__["small_jupyter"] = auto_cast &small_jupyter

		__symmap__["small_odin"] = auto_cast &small_odin

		__symmap__["tiny_odin"] = auto_cast &tiny_odin

		}

		@(export) __apply_symmap__:: proc() {

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
	 small_jupyter, _ = os.read_entire_file_from_filename(`C:\Code\jodin\examples\small-jupyter.jpg`)
	 small_odin, _ = os.read_entire_file_from_filename(`C:\Code\jodin\examples\small-odin.png`)
	 tiny_odin, _ = os.read_entire_file_from_filename(`C:\Code\jodin\examples\tiny-odin.gif`)
	 jodin.display_image(data=small_jupyter, format=jodin.Image_Format.JPEG)
	 jodin.display_image(data=small_odin, format=jodin.Image_Format.PNG)
	 jodin.display_image(data=tiny_odin, format=jodin.Image_Format.GIF, size=[2]uint{ 20, 20 })


			os.stdout = __original_stdout__
			os.stderr = __original_stderr__
		}
