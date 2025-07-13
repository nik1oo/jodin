package test_server_client_connection
import "core:fmt"
import "core:os"
import "shared:jodin/external_pipe"


main:: proc() {
	pipe: external_pipe.External_Pipe
	external_pipe.init_by_name(&pipe, "test_server_client_connection", os.O_RDONLY)
	external_pipe.connect(&pipe)
	fmt.println("done") }

