package jodin
import "base:runtime"
import "core:mem"
import "core:fmt"
import "core:slice"


Allocator:: struct {
	session: ^Session,
	backing: runtime.Allocator,
	total_memory_allocated: i64,
	disable_free: bool,
	print_allocations: bool }


allocator_init:: proc(a: ^Allocator, session: ^Session, disable_free: bool = false, print_allocations: bool = false, backing_allocator: runtime.Allocator = context.allocator) {
	a.session = session
	a.backing = backing_allocator
	a.disable_free = disable_free
	a.print_allocations = print_allocations }


@(require_results)
allocator:: proc(data: ^Allocator) -> runtime.Allocator {
	return runtime.Allocator {
		data = data,
		procedure = allocator_proc } }


allocator_proc:: proc(
	allocator_data: rawptr,
	mode:           runtime.Allocator_Mode,
	size:           int,
	alignment:      int,
	old_memory:     rawptr,
	old_size:       int,
	loc := #caller_location,
) -> ([]byte, runtime.Allocator_Error)  {
	allocator := cast(^Allocator)allocator_data
	switch mode {
	case .Alloc, .Alloc_Non_Zeroed:
		// if allocator.print_allocations do allocator.session.error_handler(nil, "Allocated %d bytes.", size, loc=loc)
		allocator.total_memory_allocated += cast(i64)size
		result, error: = mem.alloc_bytes(size, alignment, allocator.backing, loc)
		// if error != runtime.Allocator_Error.None do allocator.session.error_handler(nil, "Failed to allocate %d bytes: %v.", size, error, loc=loc)
		return result, error
	case .Free:
		if ! allocator.disable_free do return nil, mem.free(old_memory, allocator.backing, loc)
		else do return nil, nil
	case .Free_All:
		return nil, .Mode_Not_Implemented
	case .Resize, .Resize_Non_Zeroed:
		return mem.resize_bytes(slice.bytes_from_ptr(old_memory, old_size), size, alignment, allocator.backing, loc)
	case .Query_Features:
		set := (^runtime.Allocator_Mode_Set)(old_memory)
		if set != nil {
			set^ = {.Alloc, .Alloc_Non_Zeroed, .Resize, .Resize_Non_Zeroed, .Query_Features} }
		return nil, nil
	case .Query_Info:
		return nil, .Mode_Not_Implemented }
	return nil, nil }

