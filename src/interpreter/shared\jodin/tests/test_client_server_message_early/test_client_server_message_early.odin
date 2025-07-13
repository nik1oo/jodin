package test_server_client_connection
import "core:fmt"
import "core:os"
import "core:time"
import "shared:jodin/external_pipe"


main:: proc() {
	pipe: external_pipe.External_Pipe
	external_pipe.init_by_name(&pipe, "test_client_server_message_early", os.O_RDONLY)
	external_pipe.connect(&pipe)
	time.sleep(2 * time.Second)
	message, err: = external_pipe.read_string(&pipe, external_pipe.DEFAULT_TIMEOUT, external_pipe.DEFAULT_DELAY)
	assert(err == os.General_Error.None)
	assert(message == "message")
	fmt.println("done") }

