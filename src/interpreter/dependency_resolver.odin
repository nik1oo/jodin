#+private
package jodin
import "core:fmt"


determine_dependers:: proc(cell_B: ^Cell) {
	session: = cell_B.session
	if cell_B.compilation_count == 0 do return
	for cell_A_id, _ in session.cells do if cell_A_id != cell_B.id do for deprule in deprules {
		cell_A: = session.cells[cell_A_id]
		weak, strong: = deprule(cell_A, cell_B)
		if weak do append(&cell_B.weak_dependers, cell_A)
		if strong do append(&cell_B.strong_dependers, cell_A) } }


recompile_dependers:: proc(cell_B: ^Cell) {
	for &cell_A, i in cell_B.weak_dependers do if slice_contains_cell(cell_B.strong_dependers[:], cell_A) {
		recompile_cell(cell_B.session, cell_A.id, cell_A.code_raw) }
	for &cell_A in cell_B.strong_dependers {
		recompile_cell(cell_B.session, cell_A.id, cell_A.code_raw)
		cell_free_all(cell_A)
		run_cell(cell_A) }
	clear_dynamic_array(&cell_B.weak_dependers)
	clear_dynamic_array(&cell_B.strong_dependers) }


deprules: [3]proc(cell_A, cell_B: ^Cell) -> (weak, strong: bool) = {
	deprule_undeclaration,
	deprule_struct,
	deprule_proc_type_change }


deprule_undeclaration:: proc(cell_A, cell_B: ^Cell) -> (weak, strong: bool) {
	// A symbol is declared in cell B and used in cell A. If the symbol is undeclared and cell B is recompiled, cell A must also
	// be recompiled.
	return weak, strong }


deprule_struct:: proc(cell_A, cell_B: ^Cell) -> (weak, strong: bool) {
	// A struct is defined in cell B and used in cell A. If the fields of the struct are changed and cell B is recompiled, cell
	// A must also be recompiled.
	return weak, strong }


deprule_proc_type_change:: proc(cell_A, cell_B: ^Cell) -> (weak, strong: bool) {
	// A proc is defined in cell B and used in cell A. If the type of the proc is changed and cell B is recompiled, cell A must
	// also be recompiled.
	return weak, strong }


cell_free_all:: proc(cell: ^Cell) {
	free_all(cell.cell_context.allocator) }

