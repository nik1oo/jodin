package jodin
import "base:runtime"
import "core:reflect"
import "core:fmt"
import "core:mem"
import "core:dynlib"
import "core:strings"
import "core:os"
import "core:c/libc"
import "core:odin/parser"
import "core:odin/tokenizer"
import "core:odin/ast"
import "core:path/filepath"
import "core:log"
import "core:io"
import "core:slice"
import "core:time"
import "core:sys/windows"
import "core:sys/posix"
import "core:unicode/utf16"
import "core:bytes"
import "core:thread"
import "internal_pipe"
import "external_pipe"
import "poll"


Cell_State:: struct {
	package_directives: [dynamic]string,   // immediately before package declaration
	global_constants:   [dynamic]string,   // before __main__, copied to other cells
	global_variables:   [dynamic]Variable, // before __main__, linked to other cells
	global_procedures:  [dynamic]Procedure,// before __main__, exported to other cells
	main_statements:    [dynamic]string,   // inside __main__
	import_stmts:       string }  // immediately after package declaration


Cell:: struct {
	session:            ^Session,
	id:                 string,
	allocator:          mem.Tracking_Allocator,
	temp_allocator:     mem.Scratch_Allocator,
	cell_context:       runtime.Context,
	name:               string,
	package_filepath:   string,
	source_filepath:    string,
	dll_filepath:       string,
	code_raw:           string,
	code:               string,
	tags:               Tags,
	pkg:                ^ast.Package,
	prsr:               parser.Parser,
	library:            dynlib.Library,
	compiled:           bool,
	loaded:             bool,
	compilation_count:  int,
	prev:               Cell_State, // Valid only if compilation_count > 0 //
	using curr:         Cell_State,
	weak_dependers:     [dynamic]^Cell,
	strong_dependers:   [dynamic]^Cell,
	__init__:           proc(cell: ^Cell, _stdout: os.Handle, _stderr: os.Handle, _iopub: os.Handle, __symmap__: ^map[string]rawptr),
	__main__:           proc(),
	__update_symmap__:  proc(),
	__apply_symmap__:   proc(),
	stdout_pipe:        internal_pipe.Internal_Pipe,
	stderr_pipe:        internal_pipe.Internal_Pipe,
	iopub_pipe:         internal_pipe.Internal_Pipe }


Cell_Info:: struct {
	id:   string,
	name: string,
	code: string }
cell_info:: proc() -> Cell_Info {
	return Cell_Info { id = __cell__.id, name = __cell__.name, code = __cell__.code } }

