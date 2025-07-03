package reporting_allocator
import "base:runtime"
import "core:mem"
import "core:fmt"
import "core:slice"


Report_Proc:: #type proc(loc: runtime.Source_Code_Location, size: int, error: runtime.Allocator_Error, user_ptr: rawptr)


Reporting_Allocator:: struct {
	backing:             runtime.Allocator,
	report_alloc:        Report_Proc,
	report_alloc_error:  Report_Proc,
	report_free:         Report_Proc,
	report_free_error:   Report_Proc,
	report_resize:       Report_Proc,
	report_resize_error: Report_Proc,
	user_ptr:            rawptr }


wrap_allocator:: proc(
		wrapped_allocator:   runtime.Allocator,
		report_alloc:        Report_Proc = nil,
		report_alloc_error:  Report_Proc = nil,
		report_free:         Report_Proc = nil,
		report_free_error:   Report_Proc = nil,
		report_resize:       Report_Proc = nil,
		report_resize_error: Report_Proc = nil,
		user_ptr:            rawptr = nil,
		allocator_allocator: runtime.Allocator = context.allocator) -> runtime.Allocator {
	reporting_alo: = new(Reporting_Allocator, allocator=allocator_allocator)
	reporting_allocator_init(
		reporting_alo,
		report_alloc,
		report_alloc_error,
		report_free,
		report_free_error,
		report_resize,
		report_resize_error,
		user_ptr,
		wrapped_allocator)
	return reporting_allocator(reporting_alo) }


reporting_allocator_init:: proc(
		a:                   ^Reporting_Allocator,
		report_alloc:        Report_Proc = nil,
		report_alloc_error:  Report_Proc = nil,
		report_free:         Report_Proc = nil,
		report_free_error:   Report_Proc = nil,
		report_resize:       Report_Proc = nil,
		report_resize_error: Report_Proc = nil,
		user_ptr:            rawptr = nil,
		backing_allocator:   runtime.Allocator = context.allocator) {
	a.backing             = backing_allocator
	a.report_alloc        = report_alloc
	a.report_alloc_error  = report_alloc_error
	a.report_free         = report_free
	a.report_free_error   = report_free_error
	a.report_resize       = report_resize
	a.report_resize_error = report_resize_error
	a.user_ptr = user_ptr }


@(require_results)
reporting_allocator:: proc(data: ^Reporting_Allocator) -> runtime.Allocator {
	return runtime.Allocator {
		data = data,
		procedure = reporting_allocator_proc } }


reporting_allocator_proc:: proc(
	allocator_data: rawptr,
	mode:           runtime.Allocator_Mode,
	size:           int,
	alignment:      int,
	old_memory:     rawptr,
	old_size:       int,
	loc := #caller_location,
) -> ([]byte, runtime.Allocator_Error)  {
	allocator := cast(^Reporting_Allocator)allocator_data
	switch mode {
	case .Alloc, .Alloc_Non_Zeroed:
		result, error: = mem.alloc_bytes(size, alignment, allocator.backing, loc)
		if error != runtime.Allocator_Error.None do if allocator.report_alloc_error != nil do allocator.report_alloc_error(loc, size, error, allocator.user_ptr)
		return result, error
	case .Free:
		error: = mem.free(old_memory, allocator.backing, loc)
		if error != runtime.Allocator_Error.None do if allocator.report_free_error != nil do allocator.report_free_error(loc, size, error, allocator.user_ptr)
		return nil, error
	case .Free_All:
		error: = mem.free_all(allocator.backing, loc)
		if error != runtime.Allocator_Error.None do if allocator.report_free_error != nil do allocator.report_free_error(loc, size, error, allocator.user_ptr)
		return nil, error
	case .Resize, .Resize_Non_Zeroed:
		result, error: = mem.resize_bytes(slice.bytes_from_ptr(old_memory, old_size), size, alignment, allocator.backing, loc)
		if error != runtime.Allocator_Error.None do if allocator.report_resize_error != nil do allocator.report_resize_error(loc, size, error, allocator.user_ptr)
		return result, error
	case .Query_Features:
		set: = (^runtime.Allocator_Mode_Set)(old_memory)
		set^ = mem.query_features(allocator.backing, loc)
		return nil, nil
	case .Query_Info:
		return nil, nil }
	return nil, nil }

