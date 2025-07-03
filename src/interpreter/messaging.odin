package jodin
import "base:runtime"
import "core:fmt"
import "core:strings"
import "core:relative"
import "core:mem"
import "core:slice"
import "core:os"
import "core:reflect"


@(export) __cell__: ^Cell


Message_Type:: enum u8 {
	NONE =                0,
	STREAM =              1,
	DISPLAY_DATA =        2,
	UPDATE_DISPLAY_DATA = 3,
	EXECUTE_INPUT =       4,
	EXECUTE_RESULT =      5,
	ERROR =               6,
	STATUS =              7,
	CLEAR_OUTPUT =        8,
	DEBUG_EVENT =         9 }
Message_Header:: struct #packed {
	type: Message_Type,
	size: u32 }
Message:: []u8


make_empty_message:: proc() -> (message: Message) {
	message = make(Message, size_of(Message_Header))
	header: ^Message_Header = auto_cast &message[0]
	header.type = .NONE
	header.size = size_of(Message_Header)
	return message }


Stream_Message_Header:: struct #packed {
	using _: Message_Header,
	name:    [32]u8 }
@(private) make_stream_message:: proc(name: string, text: string) -> Message {
	assert(len(name) <= 32)
	header_size: = size_of(Stream_Message_Header)
	message_size: = header_size + len(text)
	header: Stream_Message_Header = {
		type = .STREAM,
		size = auto_cast message_size }
	copy_slice(header.name[0:len(name)], transmute([]u8)name[:])
	message: Message = make([]u8, message_size)
	copy_slice(message[0:header_size], reflect.as_bytes(header))
	copy_slice(message[header_size:message_size], transmute([]u8)text[:])
	return message }
stream:: proc(which: enum { STDOUT, STDERR }, text: string) -> Error {
	return send_message(make_stream_message(which == .STDOUT ? "stdout" : "stderr", text)) }


Display_Data_Message_Header:: struct #packed {
	using _:       Message_Header,
	mime_type:     [32]u8,
	width, height: u16,
	expanded:      bool,
	display_id:    [32]u8 }
@(private) make_display_data_message:: proc(data: []u8, mime_type: string, width: uint = 0, height: uint = 0, expanded: bool = true, display_id: string = "") -> Message {
	assert(len(mime_type) <= 32)
	header_size: = size_of(Display_Data_Message_Header)
	message_size: = header_size + len(data)
	header: Display_Data_Message_Header = {
		type = .DISPLAY_DATA,
		size = auto_cast message_size }
	copy_slice(header.mime_type[0:len(mime_type)], transmute([]u8)mime_type[:])
	header.width, header.height = auto_cast width, auto_cast height
	header.expanded = expanded
	message: Message = make([]u8, message_size)
	copy_slice(message[0:header_size], reflect.as_bytes(header))
	copy_slice(message[header_size:message_size], transmute([]u8)data[:])
	return message }
display_data:: proc(data: []u8, mime_type: string, width: uint = 0, height: uint = 0, expanded: bool = true, display_id: string = "") -> Error {
	return send_message(make_display_data_message(data, mime_type, width, height, expanded, display_id)) }


Update_Display_Data_Message_Header:: Display_Data_Message_Header
@(private) make_update_display_data_message:: proc(data: []u8, mime_type: string, width: uint = 0, height: uint = 0, expanded: bool = true, display_id: string = "") -> Message {
	assert(len(mime_type) <= 32)
	header_size: = size_of(Update_Display_Data_Message_Header)
	message_size: = header_size + len(data)
	header: Update_Display_Data_Message_Header = {
		type = .UPDATE_DISPLAY_DATA,
		size = auto_cast message_size }
	copy_slice(header.mime_type[0:len(mime_type)], transmute([]u8)mime_type[:])
	header.width, header.height = auto_cast width, auto_cast height
	header.expanded = expanded
	message: Message = make([]u8, message_size)
	copy_slice(message[0:header_size], reflect.as_bytes(header))
	copy_slice(message[header_size:message_size], transmute([]u8)data[:])
	return message }
@(private) send_update_display_data_message:: proc(data: []u8, mime_type: string, width: uint = 0, height: uint = 0, expanded: bool = true, display_id: string = "") -> Error {
	return send_message(make_update_display_data_message(data, mime_type, width, height, expanded, display_id)) }


Execute_Input_Message_Header:: struct #packed {
	using _:         Message_Header,
	execution_count: u16 }
@(private) make_execute_input_message:: proc(code: string, execution_count: uint = 1) -> Message {
	header_size: = size_of(Execute_Input_Message_Header)
	message_size: = header_size + len(code)
	header: Execute_Input_Message_Header = {
		type = .EXECUTE_INPUT,
		size = auto_cast message_size }
	header.execution_count = auto_cast execution_count
	message: Message = make([]u8, message_size)
	copy_slice(message[0:header_size], reflect.as_bytes(header))
	copy_slice(message[header_size:message_size], transmute([]u8)code[:])
	return message }
@(private) send_execute_input_message:: proc(code: string, execution_count: uint = 1) -> Error {
	return send_message(make_execute_input_message(code, execution_count)) }


Execute_Result_Message_Header:: struct #packed {
	using _:       Message_Header,
	mime_type:     [32]u8,
	width, height: u16,
	expanded:      bool,
	display_id:    [32]u8,
	execution_count: u16 }
@(private) make_execute_result_message:: proc(data: []u8, mime_type: string, width: uint = 0, height: uint = 0, expanded: bool = true, display_id: string = "", execution_count: uint = 1) -> Message {
	assert(len(mime_type) <= 32)
	header_size: = size_of(Execute_Result_Message_Header)
	message_size: = header_size + len(data)
	header: Execute_Result_Message_Header = {
		type = .EXECUTE_RESULT,
		size = auto_cast message_size }
	copy_slice(header.mime_type[0:len(mime_type)], transmute([]u8)mime_type[:])
	header.width, header.height = auto_cast width, auto_cast height
	header.expanded = expanded
	header.execution_count = auto_cast execution_count
	message: Message = make([]u8, message_size)
	copy_slice(message[0:header_size], reflect.as_bytes(header))
	copy_slice(message[header_size:message_size], transmute([]u8)data[:])
	return message }
@(private) send_execute_result_message:: proc(data: []u8, mime_type: string, width: uint = 0, height: uint = 0, expanded: bool = true, display_id: string = "", execution_count: uint = 1) -> Error {
	return send_message(make_execute_result_message(data, mime_type, width, height, expanded, display_id, execution_count)) }


Error_Message_Header:: struct #packed {
	using _: Message_Header,
	ename:   [32]u8,
	evalue:  [32]u8 }
@(private) make_error_message:: proc(ename: string, evalue: string, traceback: []string) -> Message {
	header_size: = size_of(Execute_Result_Message_Header)
	traceback_string: = strings.join(traceback, sep = "\x00")
	message_size: = header_size + len(traceback_string)
	header: Execute_Result_Message_Header = {
		type = .ERROR,
		size = auto_cast header_size }
	message: Message = make([]u8, message_size)
	copy_slice(message[0:header_size], reflect.as_bytes(header))
	copy_slice(message[header_size:message_size], transmute([]u8)traceback_string[:])
	return message }
@(private) send_error_message:: proc(ename: string, evalue: string, traceback: []string) -> Error {
	return send_message(make_error_message(ename, evalue, traceback)) }


Execution_State:: enum u8 { BUSY, IDLE, STARTING }
Status_Message_Header:: struct #packed {
	using _:         Message_Header,
	execution_state: Execution_State }
@(private) make_status_message:: proc(execution_state: Execution_State) -> Message {
	header_size: = size_of(Status_Message_Header)
	header: Status_Message_Header = {
		type = .STATUS,
		size = auto_cast header_size,
		execution_state = execution_state }
	message: Message = make([]u8, header_size)
	copy_slice(message[0:header_size], reflect.as_bytes(header))
	return message }
@(private) status:: proc(execution_state: Execution_State) -> Error {
	return send_message(make_status_message(execution_state)) }


Clear_Output_Message_Header:: struct #packed {
	using _: Message_Header,
	wait:    bool }
@(private) make_clear_output_message:: proc(wait: bool) -> Message {
	header_size: = size_of(Clear_Output_Message_Header)
	header: Clear_Output_Message_Header = {
		type = .CLEAR_OUTPUT,
		wait = wait }
	message: Message = make([]u8, header_size)
	copy_slice(message[0:header_size], reflect.as_bytes(header))
	return message }
clear_output:: proc(wait: bool = false) -> Error {
	return send_message(make_clear_output_message(wait)) }


Debug_Event_Message_Header:: struct #packed {
	using _: Message_Header }
@(private) make_debug_event_message:: proc() -> Message {
	header_size: = size_of(Debug_Event_Message_Header)
	header: Debug_Event_Message_Header = {
		type = .DEBUG_EVENT }
	message: Message = make([]u8, header_size)
	copy_slice(message[0:header_size], reflect.as_bytes(header))
	return message }
@(private) send_debug_event_message:: proc() -> Error {
	return send_message(make_debug_event_message()) }


@(private) make_string_message:: proc(header: $T, str: string) -> Message {
	header_size: = size_of(T)
	message_size: = header_size + len(str)
	message: Message = make([]u8, message_size)
	copy_slice(message[0:header_size], reflect.as_bytes(header))
	copy_slice(message[header_size:message_size], transmute([]u8)str[:])
	return message }


@(private) send_message:: proc(message: Message) -> Error {
	if __cell__ == nil do return General_Error.Invalid_State
	if len(message) == 0 do return General_Error.Data_Empty
	_, err: = os.write(auto_cast __cell__.iopub_pipe.input_handle, message)
	if err != os.General_Error.None do return os.Error(err)
	return NOERR }

