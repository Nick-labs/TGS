extends Node
class_name UnitManager

@export var grid: Grid
@export var unit_scene: PackedScene
@export var units_parent: Node2D

var units: Array[Unit] = []
var occupied: Dictionary = {}

func _ready():
	spawn_unit(Vector2i(3, 3), Unit.Team.PLAYER)
	spawn_unit(Vector2i(2, 4), Unit.Team.PLAYER)
	spawn_unit(Vector2i(7, 7), Unit.Team.ENEMY)
	spawn_unit(Vector2i(6, 8), Unit.Team.ENEMY)

func is_occupied(cell: Vector2i) -> bool:
	return occupied.has(cell)

func get_unit_at(cell: Vector2i) -> Unit:
	return occupied.get(cell, null)

func get_units_by_team(team: Unit.Team) -> Array[Unit]:
	var result: Array[Unit] = []
	for unit in units:
		if unit.team == team and not unit.is_dead():
			result.append(unit)
	return result

func spawn_unit(cell: Vector2i, team: Unit.Team = Unit.Team.PLAYER) -> void:
	if not grid.is_in_bounds(cell):
		return
	if occupied.has(cell):
		return

	var unit := unit_scene.instantiate() as Unit
	unit.grid = grid
	unit.team = team
	if unit.action == null:
		if team == Unit.Team.PLAYER:
			unit.action = PushAttackAction.new()
		else:
			unit.action = MeleeAttackAction.new()
	unit.set_cell(cell)

	units_parent.add_child(unit)
	units.append(unit)
	occupied[cell] = unit

func on_unit_moved(unit: Unit, old_cell: Vector2i, new_cell: Vector2i):
	occupied.erase(old_cell)
	occupied[new_cell] = unit

func remove_unit(unit: Unit):
	if unit == null:
		return
	occupied.erase(unit.cell)
	units.erase(unit)
	unit.queue_free()

func cleanup_dead_units():
	for unit in units.duplicate():
		if unit.is_dead():
			remove_unit(unit)
