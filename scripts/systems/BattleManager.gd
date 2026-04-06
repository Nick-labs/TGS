extends Node
class_name BattleManager

@export var unit_manager: UnitManager
@export var movement_system: MovementSystem
@export var grid: Grid

enum BattleState {
	IDLE,
	UNIT_SELECTED,
	UNIT_MOVING
}

var state: BattleState = BattleState.IDLE
var selected_unit: Unit = null
var reachable_cells: Array[Vector2i] = []

func select_at(cell: Vector2i):
	var unit = unit_manager.get_unit_at(cell)

	if unit != null:
		select_unit(unit)
		return
	
	try_move_command(cell)

func select_unit(unit: Unit):
	selected_unit = unit
	state = BattleState.UNIT_SELECTED

	refresh_selection()

func refresh_selection():
	grid.clear_all_highlights()

	if selected_unit == null:
		return

	reachable_cells = movement_system.get_reachable_cells(selected_unit)

	grid.show_reachable(reachable_cells)

func unselect():
	selected_unit = null

	reachable_cells.clear()
	grid.clear_reachable()

func try_move_command(cell: Vector2i):
	if selected_unit == null:
		return
	
	if not movement_system.can_move_to(selected_unit, cell):
		return
	
	if state != BattleState.UNIT_SELECTED:
		return
	
	state = BattleState.UNIT_MOVING
	
	movement_system.move_unit(selected_unit, cell)

func on_unit_move_finished():
	state = BattleState.UNIT_SELECTED
	refresh_selection()
