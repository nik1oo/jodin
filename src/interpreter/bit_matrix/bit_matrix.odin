import "core:container/bit_array"


Bit_Matrix:: struct {
	using array: bit_array.Bit_Array,
	shape:       [2]int }


clear:: proc(bm: ^Bit_Matrix) {
	bit_array.clear(&bm.array) }


destroy:: proc(bm: ^Bit_Matrix) {
	bit_array.destroy(&bm.array) }


@(private="file") array_index:: proc(bm: ^Bit_Matrix, #any_int i: uint, #any_int j: uint) -> uint {
	return j * bm.shape.x + i }


get:: proc(bm: ^Bit_Matrix, #any_int i: uint, #any_int j: uint) -> (res: bool, ok: bool) #optional_ok {
	return bit_array.get(&bm.array, array_index(bm, i, j)) }


set:: proc(bm: ^Bit_Matrix, #any_int i: uint, #any_int j: uint, set_to: bool = true, allocator := context.allocator) -> (ok: bool) {
	return bit_array.set(&bm.array, array_index(bm, i, j), set_to, allocator) }


init:: proc(bm: ^Bit_Matrix, shape: [2]int, allocator := context.allocator) -> (ok: bool) {
	bm.shape = shape
	return bit_array.init(&bm.array, shape.x * shape.y, allocator = allocator) }

