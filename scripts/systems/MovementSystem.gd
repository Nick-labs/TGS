extends Node
class_name MovementSystem

@export var grid: Grid
@export var unit_manager: UnitManager

func move_unit(unit: Unit, target_cell: Vector2i):
	if not grid.is_in_bounds(target_cell):
		return
	
	if unit_manager.is_occupied(target_cell):
		return
	
	var path := grid.find_path(unit.cell, target_cell)
	
	if path.is_empty():
		return
	
	var limited_path := _apply_move_limit(unit, path)
	
	if limited_path.is_empty():
		return
	
	var start_cell := unit.cell
	
	unit.move_along_path(limited_path)
	
	unit.move_finished.connect(func(final_cell):
		unit_manager.on_unit_moved(unit, start_cell, final_cell)
	, CONNECT_ONE_SHOT)

func _apply_move_limit(unit: Unit, path: Array[Vector2i]) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var cost := 0
	
	for i in range(1, path.size()):
		result.append(path[i])
		cost += 1
	
		if cost >= unit.move_range:
			break
	
	return result

func can_move(unit: Unit) -> bool:
	return not unit.is_moving
