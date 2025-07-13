package ipynb
import "core:reflect"
import "base:runtime"
import "core:fmt"
import "core:strings"
import "core:encoding/json"


Cell_Type:: enum {
	CODE,
	MARKDOWN }


Cell:: struct {
	type: Cell_Type,
	source: string,
	output: string }


Parser:: json.Parser


Notebook:: struct {
	cells: [dynamic]Cell,
}


make_parser:: proc(data: []u8, allocator: = context.allocator) -> Parser {
	return json.make_parser(data, allocator=allocator) }


make_notebook:: proc(allocator: = context.allocator) -> Notebook {
	return Notebook { cells=make([dynamic]Cell) } }


parse_notebook:: proc(parser: ^Parser, notebook: ^Notebook, loc: = #caller_location) -> (ok: bool) {
	ok = false
	value: json.Value
	object: json.Object
	array: json.Array
	error: json.Error
	value, error = json.parse_object(parser, loc=loc)
	object = value.(json.Object) or_return
	root: = cast(map[string]json.Value)object
	cells_array: [dynamic]json.Value = cast([dynamic]json.Value)object["cells"].(json.Array)
	for _, i in cells_array {
		cell: Cell
		cell_object: map[string]json.Value = cast(map[string]json.Value)cells_array[i].(json.Object)
		cell_type: = cell_object["cell_type"].(string)
		switch cell_type {
			case "code":     cell.type = .CODE
			case "markdown": cell.type = .MARKDOWN }
		source_array: = cell_object["source"].(json.Array)
		builder, _: = strings.builder_make_len_cap(0, 10_000, allocator=parser.allocator)
		for _, i in source_array {
			line: = source_array[i].(string)
			fmt.sbprint(&builder, line) }
		cell.source = strings.to_string(builder)
		append(&notebook.cells, cell) }
	return true }

