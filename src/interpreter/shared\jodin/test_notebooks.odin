package jodin
import "base:runtime"
import "core:os"
import "core:testing"
import "core:mem"
import "core:path/filepath"
import "core:path/slashpath"
import "core:log"
import "core:fmt"
import "core:math/rand"
import "ipynb"
import "reporting_allocator"


NOTEBOOKS_PATH:: "examples"


@(private) test_error_handler:: proc(err: Error, msg: string = "", args: ..any, loc: runtime.Source_Code_Location = #caller_location) -> Error {
	if err == NOERR do return err
	log.errorf("%s%v: %s(%d:%d): ", INTERPRETER_ERROR_PREFIX, err, loc.file_path, loc.line, loc.column)
	log.errorf(msg, ..args)
	return err }


@(private) test_report_alloc_error:: proc(loc: runtime.Source_Code_Location, size: int, error: runtime.Allocator_Error, user_ptr: rawptr) {
	test_error_handler(error, "Failed to allocate %d bytes: %v", size, error, loc) }


test_notebook:: proc(t: ^testing.T, notebook_name: string) {
	context.allocator = reporting_allocator.wrap_allocator(
		wrapped_allocator=context.allocator,
		report_alloc_error=test_report_alloc_error,
		allocator_allocator=runtime.heap_allocator())

	session: ^Session = new(Session)
	start_session(session, test_error_handler)
	log.info("Started session.")
	defer end_session(session)

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
	for notebook_cell, i in notebook.cells {
		if notebook_cell.type != .CODE do continue
		// log.info("Compiling\n", notebook_cell.source)
		cell_id: string = fmt.aprintf("%d", rand.int31())
		cell, err: = compile_new_cell(session, cell_id, notebook_cell.source, cast(uint)i)
		// testing.expectf(t, err == NOERR, "Cell %d failed with error: %v. Cell source:\n%s", i, err, cell.code)
		testing.expectf(t, err == NOERR, "Cell %d failed with error: %v.", i, err)
		// log.info(err)
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

