package test_server_client_connection
import "core:fmt"
import "core:os"
import "core:time"
import "shared:jodin/external_pipe"


main:: proc() {
	pipe: external_pipe.External_Pipe
	time.sleep(2 * time.Second)
	external_pipe.init_by_name(&pipe, "test_client_server_connection", os.O_RDONLY, 1000)
	external_pipe.connect(&pipe)
	fmt.println("done") }

