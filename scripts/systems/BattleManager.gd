extends Node
class_name BattleManager

@export var grid: Grid
@export var unit_manager: UnitManager

var selected_unit: Unit = null

func select_at(cell: Vector2i):
	var unit = unit_manager.get_unit_at(cell)

	if unit != null:
		selected_unit = unit
		print("Selected unit:", cell)
	else:
		if selected_unit != null:
			move_selected_to(cell)

func move_selected_to(cell: Vector2i):
	if selected_unit == null:
		return

	unit_manager.move_unit(selected_unit, cell)
