extends Node
class_name UnitManager

signal units_changed
signal unit_moved(unit: Unit, old_cell: Vector2i, new_cell: Vector2i)

@export var grid: Grid
@export var unit_scene: PackedScene
@export var units_parent: Node2D

var units: Array[Unit] = []
var occupied: Dictionary = {}

func _ready():
	setup_default_battlefield()

func setup_default_battlefield():
	clear_all_units()
	grid.refresh_ownership_visuals()

func clear_all_units():
	for unit in units.duplicate():
		if unit != null and is_instance_valid(unit):
			unit.queue_free()
	units.clear()
	occupied.clear()
	units_changed.emit()
	if grid != null:
		grid.refresh_ownership_visuals()

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

func spawn_unit(
	 unit_data: UnitData,
	 team: Unit.Team,
	 cell: Vector2i
	) -> void:
		
	if not grid.is_in_bounds(cell):
		return
	if occupied.has(cell):
		return

	var unit := unit_scene.instantiate() as Unit
	unit.data = unit_data
	
	unit.grid = grid
	unit.team = team
	
	unit.set_cell(cell)

	units_parent.add_child(unit)
	units.append(unit)
	occupied[cell] = unit
	units_changed.emit()

func on_unit_moved(unit: Unit, old_cell: Vector2i, new_cell: Vector2i):
	occupied.erase(old_cell)
	occupied[new_cell] = unit
	unit_moved.emit(unit, old_cell, new_cell)
	grid.refresh_ownership_visuals()

func remove_unit(unit: Unit):
	if unit == null:
		return
	occupied.erase(unit.cell)
	units.erase(unit)
	units_changed.emit()
	grid.refresh_ownership_visuals()
	_play_unit_death_and_free(unit)

func cleanup_dead_units():
	for unit in units.duplicate():
		if unit.is_dead():
			remove_unit(unit)

func _play_unit_death_and_free(unit: Unit):
	if unit == null or not is_instance_valid(unit):
		return
	unit.death_animation_finished.connect(_on_unit_death_animation_finished.bind(unit), CONNECT_ONE_SHOT)
	unit.play_death_animation()

func _on_unit_death_animation_finished(_animated_unit: Unit, queued_unit: Unit):
	if queued_unit != null and is_instance_valid(queued_unit):
		queued_unit.queue_free()
