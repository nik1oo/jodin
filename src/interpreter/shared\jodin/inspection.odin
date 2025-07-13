package jodin
import "base:runtime"
import "core:fmt"


@(private="file")
print_type_info:: proc(ti: ^runtime.Type_Info, prefix: string = "") {
	fmt.printfln("%s%-16s%s %d", ANSI_BOLD_BLUE, "Size:", ANSI_RESET, ti.size)
	fmt.printfln("%s%-16s%s %d", ANSI_BOLD_BLUE, "Alignment:", ANSI_RESET, ti.align)
	fmt.printfln("%s%-16s%s %w", ANSI_BOLD_BLUE, "Flags:", ANSI_RESET, ti.flags) }


@(private="file")
print_type_info_variant:: proc(ti: ^runtime.Type_Info, prefix: string = "") {
	switch tv in ti.variant {
		case runtime.Type_Info_Named:
			fmt.printfln("%s%s%-16s%s %s", ANSI_BOLD_BLUE, prefix, "Type Name:", ANSI_RESET, tv.name)
			fmt.printfln("%s%s%-16s%s %s", ANSI_BOLD_BLUE, prefix, "Package:", ANSI_RESET, tv.pkg)
			fmt.printfln("%s%s%-16s%s %s(%d:%d): ", ANSI_BOLD_BLUE, prefix, "Location:", ANSI_RESET, tv.loc.file_path, tv.loc.line, tv.loc.column)
			print_type_info_variant(tv.base, "Base ")
		case runtime.Type_Info_Integer:
			fmt.printfln("%s%s%-16s%s %t", ANSI_BOLD_BLUE, prefix, "Type Signed:", ANSI_RESET, tv.signed)
			fmt.printfln("%s%s%-16s%s %w", ANSI_BOLD_BLUE, prefix, "Endianness:", ANSI_RESET, tv.endianness)
		case runtime.Type_Info_Rune:
		case runtime.Type_Info_Float:
			fmt.printfln("%s%s%-16s%s %w", ANSI_BOLD_BLUE, prefix, "Endianness:", ANSI_RESET, tv.endianness)
		case runtime.Type_Info_Complex:
		case runtime.Type_Info_Quaternion:
		case runtime.Type_Info_String:
			fmt.printfln("%s%s%-16s%s %t", ANSI_BOLD_BLUE, prefix, "Is CString:", ANSI_RESET, tv.is_cstring)
		case runtime.Type_Info_Boolean:
		case runtime.Type_Info_Any:
		case runtime.Type_Info_Type_Id:
		case runtime.Type_Info_Pointer:
			print_type_info_variant(tv.elem, "Elem ")
		case runtime.Type_Info_Multi_Pointer:
			print_type_info_variant(tv.elem, "Elem ")
		case runtime.Type_Info_Procedure:
			print_type_info_variant(tv.params, "Params ")
			print_type_info_variant(tv.results, "Results ")
			fmt.printfln("%s%s%-16s%s %t", ANSI_BOLD_BLUE, prefix, "Is Variadic:", ANSI_RESET, tv.variadic)
			fmt.printfln("%s%s%-16s%s %w", ANSI_BOLD_BLUE, prefix, "Calling Convention:", ANSI_RESET, tv.convention)
		case runtime.Type_Info_Array:
			print_type_info_variant(tv.elem, "Elem ")
			fmt.printfln("%s%s%-16s%s %d", ANSI_BOLD_BLUE, prefix, "Elem Size:", ANSI_RESET, tv.elem_size)
			fmt.printfln("%s%s%-16s%s %d", ANSI_BOLD_BLUE, prefix, "Elem Size:", ANSI_RESET, tv.count)
		case runtime.Type_Info_Enumerated_Array:
			print_type_info_variant(tv.elem, "Elem ")
			print_type_info_variant(tv.elem, "Index ")
			fmt.printfln("%s%s%-16s%s %d", ANSI_BOLD_BLUE, prefix, "Elem Size:", ANSI_RESET, tv.elem_size)
			fmt.printfln("%s%s%-16s%s %d", ANSI_BOLD_BLUE, prefix, "Count:", ANSI_RESET, tv.count)
			fmt.printfln("%s%s%-16s%s %d", ANSI_BOLD_BLUE, prefix, "Min Value:", ANSI_RESET, tv.min_value)
			fmt.printfln("%s%s%-16s%s %d", ANSI_BOLD_BLUE, prefix, "Max Value:", ANSI_RESET, tv.max_value)
			fmt.printfln("%s%s%-16s%s %t", ANSI_BOLD_BLUE, prefix, "Is Sparse:", ANSI_RESET, tv.is_sparse)
		case runtime.Type_Info_Dynamic_Array:
			print_type_info_variant(tv.elem, "Elem ")
			fmt.printfln("%s%s%-16s%s %d", ANSI_BOLD_BLUE, prefix, "Elem Size:", ANSI_RESET, tv.elem_size)
		case runtime.Type_Info_Slice:
			print_type_info_variant(tv.elem, "Elem ")
			fmt.printfln("%s%s%-16s%s %d", ANSI_BOLD_BLUE, prefix, "Elem Size:", ANSI_RESET, tv.elem_size)
		case runtime.Type_Info_Parameters:
			for _, i in tv.names {
				fmt.printfln("%s%sParam %-2d %-7s%s %s", ANSI_BOLD_BLUE, prefix, i, "Name:", ANSI_RESET, tv.names[i])
				print_type_info_variant(tv.types[i], fmt.aprintf("Param %d ", i)) }
		case runtime.Type_Info_Struct:
			fmt.printfln("%s%s%-16s%s %d", ANSI_BOLD_BLUE, prefix, "Field Count:", ANSI_RESET, tv.field_count)
			fmt.printfln("%s%s%-16s%s %w", ANSI_BOLD_BLUE, prefix, "SOA Kind:", ANSI_RESET, tv.soa_kind)
			fmt.printfln("%s%s%-16s%s %d", ANSI_BOLD_BLUE, prefix, "SOA Len:", ANSI_RESET, tv.soa_len)
			print_type_info_variant(tv.soa_base_type, "SOA Base Type ")
			for _, i in 0 ..< tv.field_count {
				fmt.printfln("%s%sField %-2d %-7s%s %s", ANSI_BOLD_BLUE, prefix, i, "Name:", ANSI_RESET, tv.names[i])
				fmt.printfln("%s%sField %-2d %-7s%s %d", ANSI_BOLD_BLUE, prefix, i, "Offset:", ANSI_RESET, tv.offsets[i])
				fmt.printfln("%s%sField %-2d %-7s%s %t", ANSI_BOLD_BLUE, prefix, i, "Using:", ANSI_RESET, tv.usings[i])
				fmt.printfln("%s%sField %-2d %-7s%s %s", ANSI_BOLD_BLUE, prefix, i, "Tag:", ANSI_RESET, tv.tags[i])
				print_type_info_variant(tv.types[i], fmt.aprintf("Field %d ", i)) }
		case runtime.Type_Info_Union:
			fmt.printfln("%s%s%-16s%s %d", ANSI_BOLD_BLUE, prefix, "Tag Offset:", ANSI_RESET, tv.tag_offset)
			print_type_info_variant(tv.tag_type, "Tag Type ")
			fmt.printfln("%s%s%-16s%s %t", ANSI_BOLD_BLUE, prefix, "Custom Align:", ANSI_RESET, tv.custom_align)
			fmt.printfln("%s%s%-16s%s %t", ANSI_BOLD_BLUE, prefix, "No Nil:", ANSI_RESET, tv.no_nil)
			fmt.printfln("%s%s%-16s%s %t", ANSI_BOLD_BLUE, prefix, "Shared Nil:", ANSI_RESET, tv.shared_nil)
			for _, i in tv.variants {
				print_type_info_variant(tv.variants[i], fmt.aprintf("Variant %d ", i)) }
		case runtime.Type_Info_Enum:
			print_type_info_variant(tv.base, "Base ")
			for _, i in tv.names {
				fmt.printfln("%s%sName %-2d%-9s%s %s", ANSI_BOLD_BLUE, prefix, i, ":", ANSI_RESET, tv.names[i])
				fmt.printfln("%s%sValue %-2d%-8s%s %d", ANSI_BOLD_BLUE, prefix, i, ":", ANSI_RESET, tv.values[i]) }
		case runtime.Type_Info_Map:
			print_type_info_variant(tv.key, "Key ")
			print_type_info_variant(tv.value, "Value ")
		case runtime.Type_Info_Bit_Set:
			print_type_info_variant(tv.elem, "Elem ")
			print_type_info_variant(tv.underlying, "Underlying ")
			fmt.printfln("%s%s%-16s%s %d", ANSI_BOLD_BLUE, prefix, "Lower:", ANSI_RESET, tv.lower)
			fmt.printfln("%s%s%-16s%s %d", ANSI_BOLD_BLUE, prefix, "Upper:", ANSI_RESET, tv.upper)
		case runtime.Type_Info_Simd_Vector:
			print_type_info_variant(tv.elem, "Elem ")
			fmt.printfln("%s%s%-16s%s %d", ANSI_BOLD_BLUE, prefix, "Elem Size:", ANSI_RESET, tv.elem_size)
			fmt.printfln("%s%s%-16s%s %d", ANSI_BOLD_BLUE, prefix, "Count:", ANSI_RESET, tv.count)
		case runtime.Type_Info_Matrix:
			print_type_info_variant(tv.elem, "Elem ")
			fmt.printfln("%s%s%-16s%s %d", ANSI_BOLD_BLUE, prefix, "Elem Size:", ANSI_RESET, tv.elem_size)
			fmt.printfln("%s%s%-16s%s %d", ANSI_BOLD_BLUE, prefix, "Elem Stride:", ANSI_RESET, tv.elem_stride)
			fmt.printfln("%s%s%-16s%s %d", ANSI_BOLD_BLUE, prefix, "Row Count:", ANSI_RESET, tv.row_count)
			fmt.printfln("%s%s%-16s%s %d", ANSI_BOLD_BLUE, prefix, "Column Count:", ANSI_RESET, tv.column_count)
			fmt.printfln("%s%s%-16s%s %w", ANSI_BOLD_BLUE, prefix, "Layout:", ANSI_RESET, tv.layout)
		case runtime.Type_Info_Soa_Pointer:
			print_type_info_variant(tv.elem, "Elem ")
		case runtime.Type_Info_Bit_Field:
			print_type_info_variant(tv.backing_type, "Backing Type ")
			for _, i in 0 ..< tv.field_count {
				fmt.printfln("%s%sField %-2d %-7s%s %s", ANSI_BOLD_BLUE, prefix, i, "Name:", ANSI_RESET, tv.names[i])
				fmt.printfln("%s%sField %-2d %-7s%s %d", ANSI_BOLD_BLUE, prefix, i, "Sizes:", ANSI_RESET, tv.bit_sizes[i])
				fmt.printfln("%s%sField %-2d %-7s%s %d", ANSI_BOLD_BLUE, prefix, i, "Offset:", ANSI_RESET, tv.bit_offsets[i])
				fmt.printfln("%s%sField %-2d %-7s%s %s", ANSI_BOLD_BLUE, prefix, i, "Tag:", ANSI_RESET, tv.tags[i])
				print_type_info_variant(tv.types[i], fmt.aprintf("Field %d ", i)) } } }


inspect:: proc(x: $T) {
	fmt.printfln("%s%-16s%s %w", ANSI_BOLD_BLUE, "Value:", ANSI_RESET, x)
	fmt.printfln("%s%-16s%s %T", ANSI_BOLD_BLUE, "Type:", ANSI_RESET, x)
	ti: = type_info_of(T)
	print_type_info(ti) }


inspect_detailed:: proc(x: $T) {
	fmt.printfln("%s%-16s%s %w", ANSI_BOLD_BLUE, "Value:", ANSI_RESET, x)
	fmt.printfln("%s%-16s%s %T", ANSI_BOLD_BLUE, "Type:", ANSI_RESET, x)
	ti: = type_info_of(T)
	print_type_info(ti)
	print_type_info_variant(ti) }


inspect_allocations:: proc() {
	fmt.printfln("%s%-16s%s %d", ANSI_BOLD_BLUE, "Allocations:", ANSI_RESET, len(__cell__.dll_allocator.allocation_map))
	if len(__cell__.dll_allocator.allocation_map) > 0 {
		for _, entry in __cell__.dll_allocator.allocation_map do fmt.printfln("%s%15X:%s %s(%d:%d): %dB", ANSI_BOLD_BLUE, entry.memory, ANSI_RESET, entry.location.procedure, entry.location.line, entry.location.column, entry.size) } }

