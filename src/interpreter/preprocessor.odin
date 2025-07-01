#+private
package jodin
import "base:runtime"
import "core:reflect"
import "core:fmt"
import "core:mem"
import "core:dynlib"
import "core:strings"
import "core:strconv"
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
import "core:sys/posix"
import "core:sys/windows"
import "core:unicode/utf16"
import "core:bytes"
import "core:thread"


Tags :: struct {
	odin_path:  string,
	build_args: string,
	timeout:    int,
	async:      bool }


_node_string:: proc(file: ^ast.File, node: ast.Node) -> string {
	return file.src[node.pos.offset:node.end.offset] }


node_string:: proc(file: ^ast.File, node: ast.Node, external_variable_ident_exprs: ^[dynamic]^ast.Node) -> string {
	in_range:: proc(x, a, b: int) -> bool { return (x >= a) && (x < b) }
	hat_points: [dynamic]int = make_dynamic_array([dynamic]int)
	for i in 0..<len(external_variable_ident_exprs) {
		expr: = external_variable_ident_exprs[i]
		if in_range(expr.pos.offset, node.pos.offset, node.end.offset) do append(&hat_points, expr.end.offset) }
	if len(hat_points) == 0 do return file.src[node.pos.offset:node.end.offset]
	sb: strings.Builder = strings.builder_make_len_cap(0, 1 * mem.Kilobyte)
	defer strings.builder_destroy(&sb)
	i: = node.pos.offset
	for hat_point in hat_points {
		fmt.sbprint(&sb, file.src[i:hat_point])
		fmt.sbprint(&sb, '^')
		i = hat_point }
	if i <= node.end.offset do fmt.sbprint(&sb, file.src[i:node.end.offset])
	return strings.to_string(sb) }


stub_error_handler:: proc(pos: tokenizer.Pos, fmt: string, args: ..any) {}


correct_raw_code_pos:: proc(pos: tokenizer.Pos) -> tokenizer.Pos {
	return { file = pos.file, offset = pos.offset, line = pos.line - 1, column = pos.column } }


infer_basic_lit_type:: proc(basic_lit: ^ast.Basic_Lit, decl_type: ^string) -> bool {
	#partial switch basic_lit.tok.kind {
		case .Integer: decl_type^ = "int"; return true
		case .Float:   decl_type^ = "f64"; return true
		case .Imag:    decl_type^ = "complex64"; return true
		case .Rune:    decl_type^ = "rune"; return true
		case .String:  decl_type^ = "string"; return true
		case: return false } }


insert_package_decl:: proc(src, package_name: string) -> (res: string) {
	i: int = 0
	for {
		if (i == -1) || (src[i : i + 2] != "#+") do break
		i += strings.index(src[i:], "\n") + 1 }
	return strings.concatenate({src[:i], fmt.aprintfln("package %s", package_name), src[i:]}) }


preprocess_cell:: proc(cell: ^Cell) -> (err: Error) {
	context = cell.cell_context

	sb:=                            strings.builder_make_len_cap(0, 1 * mem.Megabyte)
	file_tags:=                     strings.builder_make_len_cap(0, 1 * mem.Kilobyte)
	package_directive_stmts:=       strings.builder_make_len_cap(0, 1 * mem.Kilobyte)
	global_constant_stmts:=         strings.builder_make_len_cap(0, 4 * mem.Kilobyte)
	global_variable_stmts:=         strings.builder_make_len_cap(0, 4 * mem.Kilobyte)
	global_procedure_stmts:=        strings.builder_make_len_cap(0, 32 * mem.Kilobyte)
	main_stmts:=                    strings.builder_make_len_cap(0, 32 * mem.Kilobyte)
	import_stmts:=                  strings.builder_make_len_cap(0, 1 * mem.Kilobyte)
	external_variable_ident_exprs:= make_dynamic_array([dynamic]^ast.Node)

	// ASSEMBLE PREPROCESSOR INPUT //
	src: = insert_package_decl(cell.code_raw, cell.name)
	// fmt.eprintln(ANSI_GREEN, "-----------------------------------------------------")
	// fmt.eprintln(src)
	// fmt.eprintln("-----------------------------------------------------", ANSI_RESET)

	// INITIALIZE PREPROCESSOR //
	NO_POS:: tokenizer.Pos{}
	pkg:= ast.new_from_positions(ast.Package, NO_POS, NO_POS)
	pkg.fullpath, _ = filepath.abs(cell.package_filepath)
	file: = ast.new(ast.File, NO_POS, NO_POS)
	file.pkg = pkg
	file.src = src
	file.fullpath, _ = filepath.abs(cell.source_filepath)
	pkg.files[file.fullpath] = file
	prsr:= parser.default_parser()
	prsr.err, prsr.warn = stub_error_handler, stub_error_handler
	ok: = parser.parse_file(&prsr, file)
	if ! ok do return error_handler(General_Error.Preprocessor_Error, "Could not parse file %s.", file.src)

	// COLLECT EXTERNAL VARIABLE IDENT EXPRS //
	// TODO This doesn't consider overshadowing. //
	Visitor_Data:: struct { cell: ^Cell, external_variable_ident_exprs: ^[dynamic]^ast.Node }
	visitor_data: Visitor_Data = { cell, &external_variable_ident_exprs }
	v := &ast.Visitor{
		visit = proc(v: ^ast.Visitor, node: ^ast.Node) -> ^ast.Visitor {
			if node == nil do return nil
			cell: = (cast(^Visitor_Data)v.data).cell
			external_variable_ident_exprs: = (cast(^Visitor_Data)v.data).external_variable_ident_exprs
			#partial switch ident in node.derived {
				case ^ast.Ident:
					is_externally_declared: bool = false
					SEARCH: for _, other_cell in cell.session.cells do if other_cell.loaded do for variable in other_cell.global_variables do if variable.name == ident.name {
						is_externally_declared = true
						break SEARCH }
					is_shadowing: bool = false  // TODO
					is_value_decl: bool = false // TODO
					if is_externally_declared && (! is_shadowing) && (! is_value_decl) do append(external_variable_ident_exprs, node) }
			return v },
		data = &visitor_data }
	ast.walk(v, &file.node)

	// PARSE TAGS //
	for tag in file.tags {
		if strings.starts_with(tag.text, "#+odin ") {
			cell.tags.odin_path = tag.text[7:] }
		else if strings.starts_with(tag.text, "#+args ") {
			cell.tags.build_args = tag.text[7:] }
		else if strings.starts_with(tag.text, "#+timeout ") {
			timeout, ok: = strconv.parse_int(tag.text[10:])
			if ok do cell.tags.timeout = timeout }
		else if strings.starts_with(tag.text, "#+async") {
			cell.tags.async = true }
		else do fmt.sbprintln(&file_tags, tag.text) }

	// PARSE DECLARATIONS //
	DECLS: for decl_node, _ in file.decls do #partial switch decl in decl_node.derived_stmt {
		case ^ast.Value_Decl:
			PREPROCESS_VALUE_DECL: {
				type_string: string = ""
				inferred_type: bool = false

				// IMMUTABLE //
				if ! decl.is_mutable {
					if len(decl.values) == 1 do #partial switch value in decl.values[0].derived_expr {
						case ^ast.Proc_Lit:
							append(&cell.global_procedures, Procedure{
								name = (decl.names[0].derived_expr.(^ast.Ident)).name,
								type = node_string(file, value.type, &external_variable_ident_exprs),
								value = node_string(file, value.body, &external_variable_ident_exprs) })
							break PREPROCESS_VALUE_DECL
						case ^ast.Basic_Lit:
							fmt.sbprintln(&global_constant_stmts, node_string(file, decl, &external_variable_ident_exprs))
							break PREPROCESS_VALUE_DECL
						case ^ast.Binary_Expr:
							fmt.sbprintln(&global_constant_stmts, node_string(file, decl, &external_variable_ident_exprs))
							break PREPROCESS_VALUE_DECL
						case:
							return error_handler(General_Error.Preprocessor_Error, "Unhandled immutable value declaration %s of type $v.", node_string(file, decl.values[0], &external_variable_ident_exprs), value) }
					fmt.sbprintln(&global_constant_stmts, node_string(file, decl, &external_variable_ident_exprs)) }

				// MUTABLE //
				if decl.type != nil do type_string = node_string(file, decl.type, &external_variable_ident_exprs)
				else do inferred_type = true
				for name, i in decl.names {
					name_string: = (name.derived_expr.(^ast.Ident)).name
					if i < len(decl.values) do #partial switch value in decl.values[i].derived_expr {
						case ^ast.Basic_Lit:
							if inferred_type do if ! infer_basic_lit_type(value, &type_string) do return error_handler(General_Error.Preprocessor_Error, correct_raw_code_pos(decl.pos), "JOdin cannot infer the type of %s. Please declare it explicitly.", name_string)
							append(&cell.global_variables, Variable{ name = name_string, type = type_string, value = node_string(file, decl.values[i], &external_variable_ident_exprs) })
						case ^ast.Comp_Lit, ^ast.Ident, ^ast.Call_Expr, ^ast.Binary_Expr, ^ast.Unary_Expr, ^ast.Paren_Expr, ^ast.Deref_Expr, ^ast.Auto_Cast:
							if inferred_type do return error_handler(General_Error.Preprocessor_Error, correct_raw_code_pos(decl.pos), "JOdin cannot infer the type of %s. Please declare it explicitly.", name_string)
							else do append(&cell.global_variables, Variable{ name = name_string, type = type_string, value = node_string(file, decl.values[i], &external_variable_ident_exprs) })
						case ^ast.Struct_Type, ^ast.Proc_Lit:
							fmt.sbprintln(&global_constant_stmts, node_string(file, decl, &external_variable_ident_exprs))
						case:
							return error_handler(General_Error.Preprocessor_Error, "Unhandled mutable value declaration %s of type %v.", node_string(file, decl.values[i], &external_variable_ident_exprs), value) }
					else {
						append(&cell.global_variables, Variable{ name = name_string, type = type_string, value = "" }) } } }
		case ^ast.Import_Decl:
			fmt.sbprintln(&import_stmts, node_string(file, decl_node, &external_variable_ident_exprs))
		case ^ast.Assign_Stmt, ^ast.Expr_Stmt, ^ast.Block_Stmt, ^ast.If_Stmt, ^ast.When_Stmt, ^ast.Defer_Stmt, ^ast.Range_Stmt:
			fmt.sbprintln(&main_stmts, '\t', node_string(file, decl_node, &external_variable_ident_exprs))
		case ^ast.For_Stmt:
			fmt.sbprintln(&main_stmts, '\t', strings.concatenate({decl.label != nil ? fmt.aprintf("%s: ", node_string(file, decl.label, &external_variable_ident_exprs)) : "", node_string(file, decl, &external_variable_ident_exprs)}))
		case ^ast.Switch_Stmt:
			fmt.sbprintln(&main_stmts, '\t', strings.concatenate({decl.partial ? "#partial " : "", node_string(file, decl, &external_variable_ident_exprs)}))
		case:
			return error_handler(General_Error.Preprocessor_Error, "Undandled declaration %s of type %T.", node_string(file, decl_node, &external_variable_ident_exprs), decl_node.derived_stmt) }

	nl:: proc(sb: ^strings.Builder) { fmt.sbprintln(sb) }

	// FILE TAGS //
	append(&sb.buf, ..file_tags.buf[:])
	nl(&sb)

	// PACKAGE DECLARATION //
	fmt.sbprintln(&sb, "package", cell.name)
	nl(&sb)

	// IMPORT DECLARATIONS //
	fmt.sbprintln(&sb,
		"import \"shared:jodin\"\n" +
		"import \"core:io\"\n" +
		"import \"core:os\"\n" +
		"import \"core:sync\"")
	for _, other_cell in cell.session.cells do if other_cell.loaded do fmt.sbprintln(&sb, other_cell.imports_string)
	append(&sb.buf, ..import_stmts.buf[:])
	nl(&sb)

	// CELL VARIABLES //
	fmt.sbprintln(&sb,
		"@(export) __cell__: ^jodin.Cell = nil\n" +
		"__data_mutex__: ^sync.Mutex = nil")
	fmt.sbprintln(&sb,
		"__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle")
	fmt.sbprintln(&sb,
		"__symmap__: ^map[string]rawptr = nil")
	nl(&sb)

	// VARIABLE DECLARATIONS //
	for _, other_cell in cell.session.cells do if other_cell.loaded do for variable in other_cell.global_variables {
		if variable_is_pointer(variable) do fmt.sbprintfln(&sb, "%s: %s", variable.name, variable.type)
		else do fmt.sbprintfln(&sb, "%s: ^%s", variable.name, variable.type) }
	for variable in cell.global_variables do fmt.sbprintfln(&sb, "%s: %s", variable.name, variable.type)
	nl(&sb)

	// EXTERNAL PROCEDURE DECLARATIONS //
	for _, other_cell in cell.session.cells do if other_cell.loaded do for procedure in other_cell.global_procedures {
		fmt.sbprintfln(&sb, "%s : %s = nil", procedure.name, procedure.type) }
	nl(&sb)

	// INTERNAL PROCEDURE DECLARATIONS //
	for procedure in cell.global_procedures {
		fmt.sbprintfln(&sb, "@(export) %s :: %s %s", procedure.name, procedure.type, procedure.value) }
	nl(&sb)

	// SYMMAP PROCS //
	fmt.sbprintln(&sb,
		"@(export) __update_symmap__:: proc() {")
	for variable in cell.global_variables do if variable_is_pointer(variable) do fmt.sbprintfln(&sb,
		"	__symmap__[\"%s\"] = auto_cast %s", variable.name, variable.name)
	else do fmt.sbprintfln(&sb,
		"	__symmap__[\"%s\"] = auto_cast &%s", variable.name, variable.name)
	fmt.sbprintln(&sb,
		"}")
	fmt.sbprintln(&sb,
		"@(export) __apply_symmap__:: proc() {")
	for _, other_cell in cell.session.cells do if other_cell.loaded do for variable in other_cell.global_variables do if variable.type[0] == '^' do fmt.sbprintfln(&sb,
		"	%s = auto_cast __symmap__[\"%s\"]", variable.name, variable.name)
	else do fmt.sbprintfln(&sb,
		"	%s = (cast(^%s)__symmap__[\"%s\"])", variable.name, variable.type, variable.name)
	for _, other_cell in cell.session.cells do if other_cell.loaded do for procedure in other_cell.global_procedures do fmt.sbprintfln(&sb,
		"	%s = auto_cast __symmap__[\"%s\"]", procedure.name, procedure.name)
	fmt.sbprintln(&sb,
		"}")
	nl(&sb)

	// GLOBAL CONSTANTS //
	for _, other_cell in cell.session.cells do if other_cell.loaded do for type in other_cell.global_constants_string do fmt.sbprintln(&sb, type)
	for type in cell.global_constants_string do fmt.sbprintln(&sb, type)
	nl(&sb)

	// INIT PROC //
	fmt.sbprintln(&sb,
		"@(export) __init__:: proc(_cell: ^jodin.Cell, _stdout: os.Handle, _stderr: os.Handle, _iopub: os.Handle, _symmap: ^map[string]rawptr) {")
	fmt.sbprintln(&sb,
		"	__data_mutex__ = _cell.session.data_mutex\n" +
		"	sync.mutex_lock(__data_mutex__); defer sync.mutex_unlock(__data_mutex__)\n" +
		"	__cell__ = _cell\n" +
		"	sync.mutex_lock(&__cell__.mutex); defer sync.mutex_unlock(&__cell__.mutex)\n" +
		"	context = __cell__.cell_context\n" +
		"	__original_stdout__ = os.stdout\n" +
		"	__original_stderr__ = os.stderr\n" +
		"	__stdout__ = _stdout; os.stdout = __stdout__\n" +
		"	__stderr__ = _stderr; os.stderr = __stderr__\n" +
		"	__iopub__ = _iopub\n" +
		"	__symmap__ = _symmap\n" +
		"}")
	nl(&sb)

	// MAIN PROC //
	fmt.sbprintln(&sb,
		"@(export) __main__:: proc() {\n" +
		"	sync.mutex_lock(__data_mutex__); defer sync.mutex_unlock(__data_mutex__)\n" if ! cell.tags.async else "" +
		"	sync.mutex_lock(&__cell__.mutex); defer sync.mutex_unlock(&__cell__.mutex)\n" +
		"	context = __cell__.cell_context\n")
	for variable in cell.global_variables do if variable.value != "" do fmt.sbprintfln(&sb, "\t%s = %s", variable.name, variable.value)
	fmt.sbprintln(&sb, strings.to_string(main_stmts))
	fmt.sbprintln(&sb,
		"	os.stdout = __original_stdout__\n" +
		"	os.stderr = __original_stderr__\n" +
		"}")

	cell.code = strings.to_string(sb)

	// SAVE THINGS FOR OTHER CELLS //
	cell.imports_string = strings.to_string(import_stmts)
	cell.global_constants_string = strings.to_string(global_constant_stmts)

	// fmt.eprintln(ANSI_BLUE, "-----------------------------------------------------")
	// fmt.eprintln(cell.code)
	// fmt.eprintln("-----------------------------------------------------", ANSI_RESET)

	return NOERR }

