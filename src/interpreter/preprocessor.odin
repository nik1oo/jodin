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


// FILE TAGS //
// #+        -- applied to current cell.
// #++       -- applied to all cells.
// #+args    -- extra build arguments.
// #+timeout -- override default cell execution timeout.
// #+odin    -- override default path to Odin.
Tags :: struct {
	odin_path: string,
	build_args: string,
	timeout: int }


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


// HANDLED //
preprocess_cell:: proc(cell: ^Cell) -> (err: Error) {

	fmt.eprintln("Starting preprocessing.")
	defer fmt.println("Exiting preprocessor.")

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
	fmt.eprintln(ANSI_GREEN, "-----------------------------------------------------")
	fmt.eprintln(src)
	fmt.eprintln("-----------------------------------------------------", ANSI_RESET)

	// INITIALIZE PREPROCESSOR //
	fmt.eprintln("Parsing declarations")
	NO_POS:: tokenizer.Pos{}
	cell.pkg = ast.new_from_positions(ast.Package, NO_POS, NO_POS)
	cell.pkg.fullpath, _ = filepath.abs(cell.package_filepath)
	file: = ast.new(ast.File, NO_POS, NO_POS)
	file.pkg = cell.pkg
	file.src = src
	file.fullpath, _ = filepath.abs(cell.source_filepath)
	cell.pkg.files[file.fullpath] = file
	cell.prsr = parser.default_parser()
	cell.prsr.err, cell.prsr.warn = stub_error_handler, stub_error_handler
	ok: = parser.parse_file(&cell.prsr, file)
	if ! ok do return error_handler(General_Error.Preprocessor_Error, "Could not parse file %s.", file.src)

	// COLLECT EXTERNAL VARIABLE IDENT EXPRS //
	// TODO This doesn't consider overshadowing. //
	fmt.eprintln("Collecting external variable ident exprs")
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
	// for i in 0 ..< len(external_variable_ident_exprs) {
	// 	fmt.eprintln(node_string(file, external_variable_ident_exprs[i]^, &external_variable_ident_exprs)) }

	// PARSE TAGS //
	cell.tags.odin_path = "odin"
	cell.tags.timeout = DEFAULT_CELL_TIMEOUT
	for tag in file.tags {
		if strings.starts_with(tag.text, "#+odin ") {
			cell.tags.odin_path = tag.text[7:] }
		else if strings.starts_with(tag.text, "#+args ") {
			cell.tags.build_args = tag.text[7:] }
		else if strings.starts_with(tag.text, "#+timeout ") {
			timeout, ok: = strconv.parse_int(tag.text[10:])
			if ok do cell.tags.timeout = timeout }
		else do fmt.sbprintln(&file_tags, tag.text) }

	// PARSE DECLARATIONS //
	DECLS: for decl_node, _ in file.decls do switch decl in decl_node.derived_stmt {
		case ^ast.Value_Decl:
			fmt.println("[ Value_Decl ]", node_string(file, decl_node, &external_variable_ident_exprs))
			PREPROCESS_VALUE_DECL: {
				type_string: string = ""
				inferred_type: bool = false

				// IMMUTABLE //
				if ! decl.is_mutable {
					if len(decl.values) == 1 do #partial switch value in decl.values[0].derived_expr {
						case ^ast.Proc_Lit:
							fmt.eprintln("[ Proc_Lit ]", node_string(file, value, &external_variable_ident_exprs))
							append(&cell.global_procedures, Procedure{
								name = (decl.names[0].derived_expr.(^ast.Ident)).name,
								type = node_string(file, value.type, &external_variable_ident_exprs),
								value = node_string(file, value.body, &external_variable_ident_exprs) })
							fmt.eprintln("[ proc ]", cell.global_procedures[len(cell.global_procedures)-1])
							break PREPROCESS_VALUE_DECL
						case ^ast.Basic_Lit:
							fmt.eprintln("[ Basic_Lit ]", node_string(file, value, &external_variable_ident_exprs))
							append(&cell.global_constants, node_string(file, decl, &external_variable_ident_exprs))
							break PREPROCESS_VALUE_DECL
						case ^ast.Binary_Expr:
							fmt.eprintln("[ Binary_Expr ]", node_string(file, value, &external_variable_ident_exprs))
							append(&cell.global_constants, node_string(file, decl, &external_variable_ident_exprs))
							break PREPROCESS_VALUE_DECL
						case:
							return error_handler(General_Error.Preprocessor_Error, "Unhandled immutable value declaration %s of type $v.", node_string(file, decl.values[0], &external_variable_ident_exprs), value) }
					append(&cell.global_constants, node_string(file, decl, &external_variable_ident_exprs)) }

				// MUTABLE //
				if decl.type != nil do type_string = node_string(file, decl.type, &external_variable_ident_exprs)
				else do inferred_type = true
				for name, i in decl.names {
					name_string: = (name.derived_expr.(^ast.Ident)).name
					if i < len(decl.values) do #partial switch value in decl.values[i].derived_expr {
						case ^ast.Basic_Lit:
							if inferred_type do if ! infer_basic_lit_type(value, &type_string) do return error_handler(General_Error.Preprocessor_Error, correct_raw_code_pos(decl.pos), "JOdin cannot infer the type of %s. Please declare it explicitly.", name_string)
							append(&cell.global_variables, Variable{ name = name_string, type = type_string, value = node_string(file, decl.values[i], &external_variable_ident_exprs) })
						case ^ast.Comp_Lit, ^ast.Ident, ^ast.Call_Expr, ^ast.Binary_Expr, ^ast.Unary_Expr, ^ast.Paren_Expr, ^ast.Deref_Expr:
							if inferred_type do return error_handler(General_Error.Preprocessor_Error, correct_raw_code_pos(decl.pos), "JOdin cannot infer the type of %s. Please declare it explicitly.", name_string)
							else do append(&cell.global_variables, Variable{ name = name_string, type = type_string, value = node_string(file, decl.values[i], &external_variable_ident_exprs) })
						case ^ast.Struct_Type, ^ast.Proc_Lit:
							append(&cell.global_constants, node_string(file, decl, &external_variable_ident_exprs))
						case:
							return error_handler(General_Error.Preprocessor_Error, "Unhandled mutable value declaration %s of type %T.", node_string(file, decl.values[i], &external_variable_ident_exprs), decl.values[i]) }
					else {
						append(&cell.global_variables, Variable{ name = name_string, type = type_string, value = "" }) } } }
		case ^ast.Import_Decl:
			fmt.println("[ Import_Decl ]", node_string(file, decl_node, &external_variable_ident_exprs))
			fmt.sbprintln(&import_stmts, node_string(file, decl_node, &external_variable_ident_exprs))
		case ^ast.Bad_Decl:
			fmt.println("[ Bad_Decl ]", node_string(file, decl_node, &external_variable_ident_exprs))
			return error_handler(General_Error.Preprocessor_Error, "Unhandled Bad_Decl: %s.", node_string(file, decl, &external_variable_ident_exprs))
		case ^ast.Bad_Stmt:
			fmt.println("[ Bad_Stmt ]", node_string(file, decl_node, &external_variable_ident_exprs))
			return error_handler(General_Error.Preprocessor_Error, "Unhandled Bad_Stmt: %s.", node_string(file, decl, &external_variable_ident_exprs))
			// #partial switch any_stmt in decl.derived_stmt {
			// 	case: fmt.eprintfln("Unhandled %s", any_stmt) }
		case ^ast.Empty_Stmt:
			fmt.println("[ Empty_Stmt ]", node_string(file, decl_node, &external_variable_ident_exprs))
			return error_handler(General_Error.Preprocessor_Error, "Unhandled Empty_Stmt: %s.", node_string(file, decl, &external_variable_ident_exprs))
		case ^ast.Tag_Stmt:
			fmt.println("[ Tag_Stmt ]", node_string(file, decl_node, &external_variable_ident_exprs))
			return error_handler(General_Error.Preprocessor_Error, "Unhandled Tag_Stmt: %s.", node_string(file, decl, &external_variable_ident_exprs))
		case ^ast.Assign_Stmt:
			fmt.println("[ Assign_Stmt ]", node_string(file, decl_node, &external_variable_ident_exprs))
			append(&cell.main_statements, node_string(file, decl_node, &external_variable_ident_exprs))
		case ^ast.Expr_Stmt:
			fmt.println("[ Expr_Stmt ]", node_string(file, decl_node, &external_variable_ident_exprs))
			append(&cell.main_statements, node_string(file, decl_node, &external_variable_ident_exprs))
		case ^ast.Block_Stmt:
			fmt.println("[ Block_Stmt ]", node_string(file, decl_node, &external_variable_ident_exprs))
			append(&cell.main_statements, node_string(file, decl_node, &external_variable_ident_exprs))
		case ^ast.If_Stmt:
			fmt.println("[ If_Stmt ]", node_string(file, decl_node, &external_variable_ident_exprs))
			append(&cell.main_statements, node_string(file, decl_node, &external_variable_ident_exprs))
		case ^ast.When_Stmt:
			fmt.println("[ When_Stmt ]", node_string(file, decl_node, &external_variable_ident_exprs))
			append(&cell.main_statements, node_string(file, decl_node, &external_variable_ident_exprs))
		case ^ast.Defer_Stmt:
			fmt.println("[ Defer_Stmt ]", node_string(file, decl_node, &external_variable_ident_exprs))
			append(&cell.main_statements, node_string(file, decl_node, &external_variable_ident_exprs))
		case ^ast.Range_Stmt:
			fmt.println("[ Range_Stmt ]", node_string(file, decl_node, &external_variable_ident_exprs))
			append(&cell.main_statements, node_string(file, decl_node, &external_variable_ident_exprs))
		case ^ast.Return_Stmt:
			fmt.println("[ Return_Stmt ]", node_string(file, decl_node, &external_variable_ident_exprs))
			return error_handler(General_Error.Preprocessor_Error, "Unhandled Return_Stmt: %s.", node_string(file, decl, &external_variable_ident_exprs))
		case ^ast.For_Stmt:
			fmt.println("[ For_Stmt ]", node_string(file, decl_node, &external_variable_ident_exprs))
			append(&cell.main_statements, strings.concatenate({decl.label != nil ? fmt.aprintf("%s: ", node_string(file, decl.label, &external_variable_ident_exprs)) : "", node_string(file, decl, &external_variable_ident_exprs)}))
		case ^ast.Unroll_Range_Stmt:
			fmt.println("[ Unroll_Range_Stmt ]", node_string(file, decl_node, &external_variable_ident_exprs))
			return error_handler(General_Error.Preprocessor_Error, "Unhandled Unroll_Range_Stmt: %s.", node_string(file, decl, &external_variable_ident_exprs))
		case ^ast.Case_Clause:
			fmt.println("[ Case_Clause ]", node_string(file, decl_node, &external_variable_ident_exprs))
			return error_handler(General_Error.Preprocessor_Error, "Unhandled Case_Clause: %s.", node_string(file, decl, &external_variable_ident_exprs))
		case ^ast.Switch_Stmt:
			fmt.println("[ Switch_Stmt ]", node_string(file, decl_node, &external_variable_ident_exprs))
			append(&cell.main_statements, strings.concatenate({decl.partial ? "#partial " : "", node_string(file, decl, &external_variable_ident_exprs)}))
		case ^ast.Type_Switch_Stmt:
			fmt.println("[ Type_Switch_Stmt ]", node_string(file, decl_node, &external_variable_ident_exprs))
			return error_handler(General_Error.Preprocessor_Error, "Unhandled Type_Switch_Stmt: %s.", node_string(file, decl, &external_variable_ident_exprs))
		case ^ast.Branch_Stmt:
			fmt.println("[ Branch_Stmt ]", node_string(file, decl_node, &external_variable_ident_exprs))
			return error_handler(General_Error.Preprocessor_Error, "Unhandled Branch_Stmt: %s.", node_string(file, decl, &external_variable_ident_exprs))
		case ^ast.Using_Stmt:
			fmt.println("[ Using_Stmt ]", node_string(file, decl_node, &external_variable_ident_exprs))
			return error_handler(General_Error.Preprocessor_Error, "Unhandled Using_Stmt: %s.", node_string(file, decl, &external_variable_ident_exprs))
		case ^ast.Package_Decl:
			fmt.println("[ Package_Decl ]", node_string(file, decl_node, &external_variable_ident_exprs))
			return error_handler(General_Error.Preprocessor_Error, "Unhandled Package_Decl: %s.", node_string(file, decl, &external_variable_ident_exprs))
		case ^ast.Foreign_Block_Decl:
			fmt.println("[ Foreign_Block_Decl ]", node_string(file, decl_node, &external_variable_ident_exprs))
			return error_handler(General_Error.Preprocessor_Error, "Unhandled Foreign_Block_Decl: %s.", node_string(file, decl, &external_variable_ident_exprs))
		case ^ast.Foreign_Import_Decl:
			fmt.println("[ Foreign_Import_Decl ]", node_string(file, decl_node, &external_variable_ident_exprs))
			return error_handler(General_Error.Preprocessor_Error, "Unhandled Foreign_Import_Decl: %s.", node_string(file, decl, &external_variable_ident_exprs))
		case:
			return error_handler(General_Error.Preprocessor_Error, "Undandled statement %s of type %T.", node_string(file, decl_node, &external_variable_ident_exprs), decl_node.derived_stmt) }

	nl:: proc(sb: ^strings.Builder) { fmt.sbprintln(sb) }

	// FILE TAGS //
	fmt.eprintln("Writing file tags")
	append(&sb.buf, ..file_tags.buf[:])
	nl(&sb)

	// PACKAGE DECLARATION //
	fmt.eprintln("Writing package declarations")
	// fmt.sbprintln(&sb, "#+feature dynamic-literals")
	fmt.sbprintln(&sb, "package", cell.name)
	nl(&sb)

	// IMPORT DECLARATIONS //
	fmt.eprintln("Writing import declarations")
	fmt.sbprintln(&sb, "import \"shared:jodin\"")
	fmt.sbprintln(&sb, "import \"core:io\"")
	fmt.sbprintln(&sb, "import \"core:os\"")
	for _, other_cell in cell.session.cells do if other_cell.loaded do fmt.sbprintln(&sb, other_cell.import_stmts)
	append(&sb.buf, ..import_stmts.buf[:])
	nl(&sb)

	// CELL VARIABLES //
	fmt.eprintln("Writing cell variables")
	fmt.sbprintln(&sb,
		"@(export) __cell__: ^jodin.Cell = nil")
	fmt.sbprintln(&sb,
		"__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle")
	fmt.sbprintln(&sb,
		"__symmap__: ^map[string]rawptr = nil")
	nl(&sb)

	// VARIABLE DECLARATIONS //
	fmt.eprintln("Writing variable declarations")
	for _, other_cell in cell.session.cells do if other_cell.loaded do for variable in other_cell.global_variables {
		if variable_is_pointer(variable) do fmt.sbprintfln(&sb, "%s: %s", variable.name, variable.type)
		else do fmt.sbprintfln(&sb, "%s: ^%s", variable.name, variable.type) }
	for variable in cell.global_variables do fmt.sbprintfln(&sb, "%s: %s", variable.name, variable.type)
	nl(&sb)

	// EXTERNAL PROCEDURE DECLARATIONS //
	fmt.eprintln("Writing external procedure declarations")
	for _, other_cell in cell.session.cells do if other_cell.loaded do for procedure in other_cell.global_procedures {
		fmt.sbprintfln(&sb, "%s : %s = nil", procedure.name, procedure.type) }
	nl(&sb)

	// INTERNAL PROCEDURE DECLARATIONS //
	fmt.eprintln("Writing internal procedure declarations")
	for procedure in cell.global_procedures {
		fmt.sbprintfln(&sb, "@(export) %s :: %s %s", procedure.name, procedure.type, procedure.value) }
	nl(&sb)

	// SYMMAP PROCS //
	fmt.eprintln("Writing symmap procs")
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
	fmt.eprintln("Writing global constants")
	for _, other_cell in cell.session.cells do if other_cell.loaded do for type in other_cell.global_constants do fmt.sbprintln(&sb, type)
	for type in cell.global_constants do fmt.sbprintln(&sb, type)
	nl(&sb)

	// INIT PROC //
	fmt.eprintln("Writing init proc")
	fmt.sbprintln(&sb,
		"@(export) __init__:: proc(_cell: ^jodin.Cell, _stdout: os.Handle, _stderr: os.Handle, _iopub: os.Handle, _symmap: ^map[string]rawptr) {")
	fmt.sbprintln(&sb,
		"	__cell__ = _cell\n" +
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
	fmt.eprintln("Writing main proc")
	fmt.sbprintln(&sb,
		"@(export) __main__:: proc() {\n" +
		"	context = __cell__.cell_context\n")
	for variable in cell.global_variables do if variable.value != "" do fmt.sbprintfln(&sb, "\t%s = %s", variable.name, variable.value)
	for expression in cell.main_statements do fmt.sbprintfln(&sb, "\t%s", expression)
	fmt.sbprintln(&sb,
		// "	os.flush(os.stdout)\n" +
		// "	os.flush(os.stderr)\n" +
		// "	message: = jodin.make_empty_message()\n" +
		// "	os.write(auto_cast __cell__.iopub_pipe.input_handle, message)\n" +
		"	os.stdout = __original_stdout__\n" +
		"	os.stderr = __original_stderr__\n" +
		"}")

	cell.code = strings.to_string(sb)

	// SAVE THINGS FOR OTHER CELLS //
	cell.import_stmts = strings.to_string(import_stmts)

	fmt.eprintln(ANSI_BLUE, "-----------------------------------------------------")
	fmt.eprintln(cell.code)
	fmt.eprintln("-----------------------------------------------------", ANSI_RESET)

	return NOERR }

