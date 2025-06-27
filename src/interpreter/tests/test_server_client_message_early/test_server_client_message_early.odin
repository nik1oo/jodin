package test_server_client_connection
import "core:fmt"
import "core:os"
import "core:time"
import "shared:jodin/external_pipe"


main:: proc() {
	pipe: external_pipe.External_Pipe
	external_pipe.init_by_name(&pipe, "test_server_client_message_early", os.O_WRONLY)
	external_pipe.connect(&pipe)
	external_pipe.write_string(&pipe, "message", external_pipe.DEFAULT_TIMEOUT, external_pipe.DEFAULT_DELAY)
	fmt.println("done") }

