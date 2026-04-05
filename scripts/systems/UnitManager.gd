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

	occupied.erase(unit.cell)

	unit.set_cell(target_cell)

	occupied[target_cell] = unit
