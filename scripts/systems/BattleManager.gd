extends Node
class_name BattleManager

@export var unit_manager: UnitManager
@export var movement_system: MovementSystem

var selected_unit: Unit = null

func select_at(cell: Vector2i):
	var unit = unit_manager.get_unit_at(cell)

	if unit != null:
		select_unit(unit)
		return
	
	try_move_command(cell)

func select_unit(unit: Unit):
	selected_unit = unit

func unselect():
	selected_unit = null

func try_move_command(cell: Vector2i):
	if selected_unit == null:
		return
	
	if not movement_system.can_move(selected_unit):
		return
	
	movement_system.move_unit(selected_unit, cell)
