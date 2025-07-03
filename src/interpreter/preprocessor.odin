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
	async:      bool,
	no_link:    bool }


node_to_string:: proc(pp: ^Preprocessor, node: ast.Node) -> string {
	return pp.file.src[node.pos.offset:node.end.offset] }


preprocess_node:: proc(pp: ^Preprocessor, node: ast.Node, async: bool = false) -> string {
	// TODO Throw error if an external variable is found and the current scope is async. //
	hat_points: [dynamic]int = make_dynamic_array([dynamic]int)
	for i in 0..<len(pp.external_variable_nodes) {
		expr: = pp.external_variable_nodes[i]
		if in_range(expr.pos.offset, node.pos.offset, node.end.offset) do append(&hat_points, expr.end.offset) }
	if len(hat_points) == 0 do return pp.file.src[node.pos.offset:node.end.offset]
	sb: strings.Builder = strings.builder_make_len_cap(0, 1 * mem.Kilobyte)
	defer strings.builder_destroy(&sb)
	i: = node.pos.offset
	for hat_point in hat_points {
		fmt.sbprint(&sb, pp.file.src[i:hat_point])
		fmt.sbprint(&sb, '^')
		i = hat_point }
	if i <= node.end.offset do fmt.sbprint(&sb, pp.file.src[i:node.end.offset])
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


Preprocessor:: struct {
	cell:                    ^Cell,
	external_variable_nodes: [dynamic]^ast.Node,
	file:                    ^ast.File,
	sync_scopes:             [dynamic][2]int,
	err:                     Error }


preprocess_cell:: proc(cell: ^Cell) -> (err: Error) {

	// SUPPORT PROCS //
	stmt_label:: proc(pp: ^Preprocessor, stmt: ast.Any_Stmt) -> string {
		#partial switch derived in stmt {
		case ^ast.Block_Stmt:        return node_to_string(pp, derived.label) if derived.label != nil else ""
		case ^ast.If_Stmt:           return node_to_string(pp, derived.label) if derived.label != nil else ""
		case ^ast.For_Stmt:          return node_to_string(pp, derived.label) if derived.label != nil else ""
		case ^ast.Range_Stmt:        return node_to_string(pp, derived.label) if derived.label != nil else ""
		case ^ast.Unroll_Range_Stmt: return node_to_string(pp, derived.label) if derived.label != nil else ""
		case ^ast.Switch_Stmt:       return node_to_string(pp, derived.label) if derived.label != nil else ""
		case ^ast.Type_Switch_Stmt:  return node_to_string(pp, derived.label) if derived.label != nil else ""
		case ^ast.Branch_Stmt:       return node_to_string(pp, derived.label) if derived.label != nil else ""
		case:                        return "" } }
	node_is_synced:: proc(pp: ^Preprocessor, node: ^ast.Node) -> bool {
		scope: = [2]int{ node.pos.offset, node.end.offset }
		return slice.contains(pp.sync_scopes[:], scope) }

	context = cell.cell_context
	session: = cell.session

	pp: Preprocessor = {
		cell = cell,
		external_variable_nodes = make_dynamic_array([dynamic]^ast.Node),
		sync_scopes = make([dynamic][2]int),
		err = NOERR }

	sb:=                            strings.builder_make_len_cap(0, 1 * mem.Megabyte)
	file_tags:=                     strings.builder_make_len_cap(0, 1 * mem.Kilobyte)
	package_directive_stmts:=       strings.builder_make_len_cap(0, 1 * mem.Kilobyte)
	global_constant_stmts:=         strings.builder_make_len_cap(0, 4 * mem.Kilobyte)
	global_variable_stmts:=         strings.builder_make_len_cap(0, 4 * mem.Kilobyte)
	global_procedure_stmts:=        strings.builder_make_len_cap(0, 32 * mem.Kilobyte)
	main_stmts:=                    strings.builder_make_len_cap(0, 32 * mem.Kilobyte)
	import_stmts:=                  strings.builder_make_len_cap(0, 1 * mem.Kilobyte)

	// ASSEMBLE PREPROCESSOR INPUT //
	src: = insert_package_decl(cell.code_raw, cell.name)
	// fmt.eprintln(ANSI_GREEN, "-----------------------------------------------------")
	// fmt.eprintln(src)
	// fmt.eprintln("-----------------------------------------------------", ANSI_RESET)

	// INITIALIZE PREPROCESSOR //
	NO_POS:: tokenizer.Pos{}
	pkg:= ast.new_from_positions(ast.Package, NO_POS, NO_POS)
	pkg.fullpath, _ = filepath.abs(cell.package_filepath)
	pp.file = ast.new(ast.File, NO_POS, NO_POS)
	pp.file.pkg = pkg
	pp.file.src = src
	pp.file.fullpath, _ = filepath.abs(cell.source_filepath)
	pkg.files[pp.file.fullpath] = pp.file
	prsr:= parser.default_parser()
	prsr.err, prsr.warn = stub_error_handler, stub_error_handler
	ok: = parser.parse_file(&prsr, pp.file)
	if ! ok do return session.error_handler(General_Error.Preprocessor_Error, "Could not parse file %s.", pp.file.src)

	// COLLECT SYNC SCOPES //
	v: = &ast.Visitor {
		visit = proc(v: ^ast.Visitor, node: ^ast.Node) -> ^ast.Visitor {
			if node == nil do return nil
			pp: ^Preprocessor = cast(^Preprocessor)v.data
			scope: = [2]int{node.pos.offset, node.end.offset}
			SYNC_LABEL:: "sync"
			#partial switch stmt in node.derived {
				case ^ast.Block_Stmt:        if stmt.label!=nil do if node_to_string(pp, stmt.label) == SYNC_LABEL do append(&pp.sync_scopes, scope)
				case ^ast.If_Stmt:           if stmt.label!=nil do if node_to_string(pp, stmt.label) == SYNC_LABEL do append(&pp.sync_scopes, scope)
				case ^ast.For_Stmt:          if stmt.label!=nil do if node_to_string(pp, stmt.label) == SYNC_LABEL do append(&pp.sync_scopes, scope)
				case ^ast.Range_Stmt:        if stmt.label!=nil do if node_to_string(pp, stmt.label) == SYNC_LABEL do append(&pp.sync_scopes, scope)
				case ^ast.Unroll_Range_Stmt: if stmt.label!=nil do if node_to_string(pp, stmt.label) == SYNC_LABEL do append(&pp.sync_scopes, scope) }
			return v },
		data = &pp }
	ast.walk(v, &pp.file.node)

	// COLLECT EXTERNAL VARIABLE NODES //
	// TODO This doesn't consider overshadowing. //
	EVI_expr_is_valid:: proc(pp: ^Preprocessor, node: ^ast.Node) -> bool {
		if ! pp.cell.tags.async do return true
		for scope in pp.sync_scopes do if in_range(node.pos.offset, scope[0], scope[1]) do return true
		return false }
	v = &ast.Visitor {
		visit = proc(v: ^ast.Visitor, node: ^ast.Node) -> ^ast.Visitor {
			if node == nil do return nil
			pp: ^Preprocessor = cast(^Preprocessor)v.data
			#partial switch ident in node.derived {
				case ^ast.Ident:
					is_externally_declared: bool = false
					SEARCH: for _, other_cell in pp.cell.session.cells do if other_cell.loaded do for variable in other_cell.global_variables do if variable.name == ident.name {
						is_externally_declared = true
						break SEARCH }
					is_shadowing: bool = false  // TODO
					is_value_decl: bool = false // TODO
					if is_externally_declared && (! is_shadowing) && (! is_value_decl) {
						append(&pp.external_variable_nodes, node) } }
						// if EVI_expr_is_valid(pp, node) do append(&pp.external_variable_nodes, node)
						// else do pp.err = session.error_handler(General_Error.Preprocessor_Error, "References to external variables in `#+async` cells are only allowed inside scopes labeled by `sync:`.") } }
			return v },
		data = &pp }
	ast.walk(v, &pp.file.node)

	// PARSE TAGS //
	for tag in pp.file.tags {
		if strings.starts_with(tag.text, "#+odin ") {
			cell.tags.odin_path = tag.text[7:] }
		else if strings.starts_with(tag.text, "#+args ") {
			cell.tags.build_args = tag.text[7:] }
		else if strings.starts_with(tag.text, "#+timeout ") {
			timeout, ok: = strconv.parse_int(tag.text[10:])
			if ok do cell.tags.timeout = timeout }
		else if strings.starts_with(tag.text, "#+async") {
			cell.tags.async = true }
		else if strings.starts_with(tag.text, "#+no-link") {
			cell.tags.no_link = true }
		else do fmt.sbprintln(&file_tags, tag.text) }

	// PARSE DECLARATIONS //
	// for decl_node, _ in pp.file.decls {
	// 	fmt.printfln("%s%T:%s %s", ANSI_BOLD_BLUE, reflect.get_union_variant(decl_node.derived_stmt), ANSI_RESET, preprocess_node(&pp, decl_node)) }
	DECLS: for decl_node, _ in pp.file.decls do #partial switch decl in decl_node.derived_stmt {
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
								type = preprocess_node(&pp, value.type),
      								value = preprocess_node(&pp, value.body) }      )
							break PREPROCESS_VALUE_DECL
						case ^ast.Basic_Lit:
							fmt.sbprintln(&global_constant_stmts, preprocess_node(&pp, decl))
      							break PREPROCESS_VALUE_DECL
						case ^ast.Binary_Expr:
							fmt.sbprintln(&global_constant_stmts, preprocess_node(&pp, decl))
      							break PREPROCESS_VALUE_DECL
						case:
							return session.error_handler(General_Error.Preprocessor_Error, "Unhandled immutable value declaration %s of type $v.", preprocess_node(&pp, decl.values[0]), value) }
					fmt.sbprintln(&global_constant_stmts, preprocess_node(&pp, decl))       }

				// MUTABLE //
				if decl.type != nil do type_string = preprocess_node(&pp, decl.type)
	      			else do inferred_type = true
				for name, i in decl.names {
					name_string: = (name.derived_expr.(^ast.Ident)).name
					if i < len(decl.values) do #partial switch value in decl.values[i].derived_expr {
						case ^ast.Basic_Lit:
							if inferred_type do if ! infer_basic_lit_type(value, &type_string) do return session.error_handler(General_Error.Preprocessor_Error, "JOdin cannot infer the type of %s. Please declare it explicitly.", name_string, correct_raw_code_pos(decl.pos))
							if ! cell.tags.async do append(&cell.global_variables, Variable{ name = name_string, type = type_string, value = preprocess_node(&pp, decl.values[i]) })
							else do fmt.sbprintln(&main_stmts, `			`, preprocess_node(&pp, decl_node))
						case ^ast.Comp_Lit, ^ast.Ident, ^ast.Call_Expr, ^ast.Binary_Expr, ^ast.Unary_Expr, ^ast.Paren_Expr, ^ast.Deref_Expr, ^ast.Auto_Cast:
							if inferred_type do return session.error_handler(General_Error.Preprocessor_Error, "JOdin cannot infer the type of %s. Please declare it explicitly.", name_string, correct_raw_code_pos(decl.pos))
							else if ! cell.tags.async do append(&cell.global_variables, Variable{ name = name_string, type = type_string, value = preprocess_node(&pp, decl.values[i]) })
							else do fmt.sbprintln(&main_stmts, `			`, preprocess_node(&pp, decl_node), sep=``)
						case ^ast.Struct_Type, ^ast.Proc_Lit:
							fmt.sbprintln(&global_constant_stmts, preprocess_node(&pp, decl))
      						case:
							return session.error_handler(General_Error.Preprocessor_Error, "Unhandled mutable value declaration %s of type %v.", preprocess_node(&pp, decl.values[i]), value) }
					else {
						if ! cell.tags.async do append(&cell.global_variables, Variable{ name = name_string, type = type_string, value = "" })
							else do fmt.sbprintln(&main_stmts, `			`, preprocess_node(&pp, decl_node), sep=``) } } }
		case ^ast.Import_Decl:
			fmt.sbprintln(&import_stmts, `		`, preprocess_node(&pp, decl_node), sep=``)
  		case ^ast.Assign_Stmt, ^ast.Expr_Stmt, ^ast.When_Stmt, ^ast.Defer_Stmt:
			fmt.sbprintln(&main_stmts, '\t', preprocess_node(&pp, decl_node))
		case ^ast.For_Stmt:
  			label, synced: = stmt_label(&pp, decl), node_is_synced(&pp, decl_node)
  			if (label != "" && ! synced) do fmt.sbprintf(
  				&main_stmts,
  				`	%s: `,
  				label)
  			else do fmt.sbprint(
  				&main_stmts,
  				`	`)
			fmt.sbprintfln(
				&main_stmts,
				`	for %s; %s; %s %s`,
				decl.init != nil ? preprocess_node(&pp, decl.init) : ``,
				decl.cond != nil ? preprocess_node(&pp, decl.cond) : ``,
				decl.post != nil ? preprocess_node(&pp, decl.post) : ``,
				`{`)
			if synced do fmt.sbprintln(&main_stmts,
				`		sync.ticket_mutex_lock(__data_mutex__)` + NL +
				`		defer sync.ticket_mutex_unlock(__data_mutex__)`)
			fmt.sbprintln(
				&main_stmts,
				decl.body != nil ? preprocess_node(&pp, decl.body) : ``)
			fmt.sbprintln(
				&main_stmts,
				`	}`)
  		case ^ast.Block_Stmt, ^ast.If_Stmt, ^ast.Range_Stmt, ^ast.Unroll_Range_Stmt:
  			label, synced: = stmt_label(&pp, decl), node_is_synced(&pp, decl_node)
			if synced do fmt.sbprintln(&main_stmts,
				`sync.ticket_mutex_lock(__data_mutex__)`)
			fmt.sbprintln(&main_stmts, `
				`, strings.concatenate({(label != "" && ! synced) ? fmt.aprintf("%s: ", label) : "", preprocess_node(&pp, decl_node)}), sep=``)
			if synced do fmt.sbprintln(&main_stmts, `
				sync.ticket_mutex_unlock(__data_mutex__)`)
		case ^ast.Switch_Stmt:
			fmt.sbprintln(&main_stmts, '\t', strings.concatenate({decl.partial ? "#partial " : "", preprocess_node(&pp, decl)}))
		case:
			return session.error_handler(General_Error.Preprocessor_Error, "Undandled declaration %s of type %T.", preprocess_node(&pp, decl_node), decl_node.derived_stmt) }

	nl:: proc(sb: ^strings.Builder) { fmt.sbprintln(sb) }

	// FILE TAGS //
	append(&sb.buf, ..file_tags.buf[:])
	nl(&sb)

	// PACKAGE DECLARATION //
	fmt.sbprintfln(&sb, `
		package %s`, cell.name)

	// IMPORT DECLARATIONS //
	fmt.sbprintln(&sb, `
		import "shared:jodin"
		import "core:io"
		import "core:os"
		import "core:sync"`)
	for _, other_cell in cell.session.cells do if other_cell.loaded do fmt.sbprintln(&sb, other_cell.imports_string)
	append(&sb.buf, ..import_stmts.buf[:])

	// CELL VARIABLES //
	fmt.sbprintln(&sb, `
		@(export) __cell__: ^jodin.Cell = nil
		__data_mutex__: ^sync.Ticket_Mutex = nil
		__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
		__symmap__: ^map[string]rawptr = nil`)

	// VARIABLE DECLARATIONS //
	for _, other_cell in cell.session.cells do if other_cell.loaded do for variable in other_cell.global_variables {
		if variable_is_pointer(variable) do fmt.sbprintfln(&sb, `
			%s: %s`,
			variable.name, variable.type)
		else do fmt.sbprintfln(&sb, `
			%s: ^%s`,
			variable.name, variable.type) }
	for variable in cell.global_variables do fmt.sbprintfln(&sb, "%s: %s", variable.name, variable.type)

	// EXTERNAL PROCEDURE DECLARATIONS //
	for _, other_cell in cell.session.cells do if other_cell.loaded do for procedure in other_cell.global_procedures {
		fmt.sbprintfln(&sb, `
			%s : %s = nil`,
			procedure.name, procedure.type) }

	// INTERNAL PROCEDURE DECLARATIONS //
	for procedure in cell.global_procedures {
		fmt.sbprintfln(&sb, `
			@(export) %s :: %s %s`,
			procedure.name, procedure.type, procedure.value) }

	// SYMMAP PROCS //
	fmt.sbprintln(&sb, `
		@(export) __update_symmap__:: proc() {`)
	for variable in cell.global_variables do if variable_is_pointer(variable) do fmt.sbprintfln(&sb, `
		__symmap__["%s"] = auto_cast %s`,
		variable.name, variable.name)
	else do fmt.sbprintfln(&sb, `
		__symmap__["%s"] = auto_cast &%s`,
		variable.name, variable.name)
	fmt.sbprintln(&sb, `
		}`)
	fmt.sbprintln(&sb, `
		@(export) __apply_symmap__:: proc() {`)
	for _, other_cell in cell.session.cells do if other_cell.loaded do for variable in other_cell.global_variables do if variable.type[0] == '^' do fmt.sbprintfln(&sb, `
		%s = auto_cast __symmap__["%s"]`,
		variable.name, variable.name)
	else do fmt.sbprintfln(&sb, `
		%s = (cast(^%s)__symmap__["%s"])
	`, variable.name, variable.type, variable.name)
	for _, other_cell in cell.session.cells do if other_cell.loaded do for procedure in other_cell.global_procedures do fmt.sbprintfln(&sb, `
		%s = auto_cast __symmap__["%s"]`,
		procedure.name, procedure.name)
	fmt.sbprintln(&sb, `
		}`)

	// GLOBAL CONSTANTS //
	for _, other_cell in cell.session.cells do if other_cell.loaded do fmt.sbprintln(&sb, other_cell.global_constants_string)
	fmt.sbprintln(&sb, strings.to_string(global_constant_stmts))

	// INIT PROC //
	fmt.sbprintln(&sb, `
		@(export) __init__:: proc(_cell: ^jodin.Cell, _stdout: os.Handle, _stderr: os.Handle, _iopub: os.Handle, _symmap: ^map[string]rawptr) {
			__data_mutex__ = &_cell.session.data_mutex
			sync.ticket_mutex_lock(__data_mutex__); defer sync.ticket_mutex_unlock(__data_mutex__)
			__cell__ = _cell
			sync.mutex_lock(&__cell__.mutex); defer sync.mutex_unlock(&__cell__.mutex)
			context = __cell__.cell_context
			__original_stdout__ = os.stdout
			__original_stderr__ = os.stderr
			__stdout__ = _stdout; os.stdout = __stdout__
			__stderr__ = _stderr; os.stderr = __stderr__
			__iopub__ = _iopub
			__symmap__ = _symmap
		}`)

	// MAIN PROC //
	fmt.sbprintln(&sb, `
		@(export) __main__:: proc() {`)
	if ! cell.tags.async do fmt.sbprintln(&sb, `
			sync.ticket_mutex_lock(__data_mutex__); defer sync.ticket_mutex_unlock(__data_mutex__)`)
	fmt.sbprintln(&sb, `
			sync.mutex_lock(&__cell__.mutex); defer sync.mutex_unlock(&__cell__.mutex)
			context = __cell__.cell_context`)
	for variable in cell.global_variables do if variable.value != "" do fmt.sbprintfln(&sb, "\t%s = %s", variable.name, variable.value)
	fmt.sbprintln(&sb, strings.to_string(main_stmts))
	fmt.sbprintln(&sb, `
			os.stdout = __original_stdout__
			os.stderr = __original_stderr__
		}`)

	cell.code = strings.to_string(sb)

	// SAVE THINGS FOR OTHER CELLS //
	cell.imports_string = strings.to_string(import_stmts)
	cell.global_constants_string = strings.to_string(global_constant_stmts)

	// print_cell_code(cell)

	return NOERR }

