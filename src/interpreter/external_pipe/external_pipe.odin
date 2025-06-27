package external_pipe
import "core:fmt"
import "core:os"
import "core:unicode/utf16"
import "core:time"
import "../poll"


DEFAULT_TIMEOUT:: 10 * time.Second
DEFAULT_DELAY:: 100 * time.Millisecond
External_Pipe:: struct {
	path:   string,
	handle: os.Handle }


init_by_name:: proc(pipe: ^External_Pipe, name: string, $mode: int) -> (err: os.Error) {
	return init_by_path(pipe, make_path(name), mode) }


read_string:: proc{ read_string_async, read_string_sync }
read_string_async:: proc(pipe: ^External_Pipe) -> (output: string, err: os.Error) {
	output_bytes: []u8; output_bytes, err = os.read_entire_file_from_handle_or_err(pipe.handle)
	return string(output_bytes), err }
read_string_sync:: proc(pipe: ^External_Pipe, timeout: time.Duration, delay: time.Duration) -> (output: string, err: os.Error) {
	output_bytes: []u8
	start_time: = poll.start()
	for poll.poll(start_time, timeout, delay) {
		output_bytes, err = os.read_entire_file_from_handle_or_err(pipe.handle)
		if (err == os.General_Error.None) && (len(output_bytes) > 0) do break }
	if poll.timed_out(start_time, timeout) do os.Error(os.General_Error.Timeout)
	return string(output_bytes), err }


read_bytes:: proc{ read_bytes_async, read_bytes_sync }
read_bytes_async:: proc(pipe: ^External_Pipe) -> (output: []u8, err: os.Error) {
	return os.read_entire_file_from_handle_or_err(pipe.handle) }
read_bytes_sync:: proc(pipe: ^External_Pipe, timeout: time.Duration, delay: time.Duration) -> (output: []u8, err: os.Error) {
	output_bytes: []u8
	start_time: = poll.start()
	for poll.poll(start_time, timeout, delay) {
		output_bytes, err = os.read_entire_file_from_handle_or_err(pipe.handle)
		if (err == os.General_Error.None) && (len(output_bytes) > 0) do break }
	if poll.timed_out(start_time, timeout) do os.Error(os.General_Error.Timeout)
	return output_bytes, err }


write_string:: proc{ write_string_async, write_string_sync }
write_string_async:: proc(pipe: ^External_Pipe, input: string) -> (err: os.Error) {
	_, err = os.write_string(pipe.handle, input)
	return err }
write_string_sync:: proc(pipe: ^External_Pipe, input: string, timeout: time.Duration, delay: time.Duration) -> (err: os.Error) {
	start_time: = poll.start()
	for poll.poll(start_time, timeout, delay) {
		_, err = os.write_string(pipe.handle, input)
		if err == os.General_Error.None do break }
	if poll.timed_out(start_time, timeout) do os.Error(os.General_Error.Timeout)
	return os.General_Error.None }


write_bytes:: proc { write_bytes_async, write_bytes_sync }
write_bytes_async:: proc(pipe: ^External_Pipe, input: []u8) -> (err: os.Error) {
	_, err = os.write(pipe.handle, input)
	return err }
write_bytes_sync:: proc(pipe: ^External_Pipe, input: []u8, timeout: time.Duration, delay: time.Duration) -> (err: os.Error) {
	start_time: = poll.start()
	for poll.poll(start_time, timeout, delay) {
		_, err = os.write(pipe.handle, input)
		if err == os.General_Error.None do break }
	if poll.timed_out(start_time, timeout) do os.Error(os.General_Error.Timeout)
	return os.General_Error.None }

