package jodin
import "base:runtime"
import "core:os"
import "core:testing"
import "core:mem"
import "core:path/filepath"
import "core:path/slashpath"
import "core:log"
import "ipynb"


NOTEBOOKS_PATH:: "examples"


test_notebook:: proc(t: ^testing.T, notebook_name: string) {
	filepath: = slashpath.join({NOTEBOOKS_PATH, notebook_name})
	log.info("Filepath:", filepath)
	// arena: mem.Arena
	// mem.arena_init(&arena, make([]u8, 100_000))
	// context.allocator = mem.arena_allocator(&arena)
	// start session //
	data, ok: = os.read_entire_file_from_filename(filepath)
	testing.expectf(t, ok, "Could not find %s.", filepath)
	parser: = ipynb.make_parser(data)
	notebook: = ipynb.make_notebook()
	ok = ipynb.parse_notebook(&parser, &notebook)
	testing.expectf(t, ok, "Could not parse notebook %s.", filepath)
	for cell in notebook.cells {
		log.info(len(cell.source))
		// execute cell and assert that it completed //
	}
	free_all(context.allocator)
}


@(test)
test_demo:: proc(t: ^testing.T) {
	test_notebook(t, "demo.ipynb") }


@(test)
test_display:: proc(t: ^testing.T) {
	test_notebook(t, "display.ipynb") }

