extends Node
class_name UnitManager

@export var grid: Grid
@export var unit_scene: PackedScene

var units: Array = []
var occupied: Dictionary = {} # cell → unit

func _ready():
	spawn_unit(Vector2i(3, 3))
	spawn_unit(Vector2i(5, 5))

func is_occupied(cell: Vector2i) -> bool:
	return occupied.has(cell)

func get_unit_at(cell: Vector2i) -> Unit:
	return occupied.get(cell, null)

func spawn_unit(cell: Vector2i) -> void:
	if not grid.is_in_bounds(cell):
		return

	if occupied.has(cell):
		return

	var unit := unit_scene.instantiate()

	unit.grid = grid
	unit.set_cell(cell)

	add_child(unit)

	units.append(unit)
	occupied[cell] = unit

func move_unit(unit: Unit, target_cell: Vector2i):
	if not grid.is_in_bounds(target_cell):
		return
	
	if occupied.has(target_cell):
		return
	
	var path := grid.find_path(unit.cell, target_cell)
	
	if path.is_empty():
		return
	
	unit.move_along_path(path)
	
	occupied.erase(unit.cell)
	
	unit.move_finished.connect(func(final_cell):
		occupied.erase(unit.cell)
		occupied[final_cell] = unit,
		CONNECT_ONE_SHOT
	)
