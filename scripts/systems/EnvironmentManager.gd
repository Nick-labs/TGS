extends Node
class_name EnvironmentManager

signal objective_updated(current_hp: int, max_hp: int, cell: Vector2i)
signal objective_destroyed(cell: Vector2i)
signal power_grid_updated(current_hp: int, max_hp: int)

@export var grid: Grid
@export var objective_marker: Node2D
@export var objective_cell: Vector2i
@export var objective_max_hp: int

#var units: Array[Unit] = []

var objects: Dictionary = {}

@export var battle_object_scene: PackedScene
@export var battle_objects_parent: Node2D

var objective_hp: int = 0
#var grid_buildings: Dictionary = {}
var power_grid_hp: int = 0
var power_grid_max_hp: int = 0

func _ready():
	reset_state()

func reset_state():
	objects.clear()
	objective_hp = objective_max_hp
	_refresh_objective_marker()
	objective_updated.emit(objective_hp, objective_max_hp, objective_cell)

func spawn_object(
	 object_data: ObjectData,
	 cell: Vector2i
	) -> void:
		
	if not grid.is_in_bounds(cell):
		return
		
	#if occupied.has(cell):
		#return

	var object := battle_object_scene.instantiate() as BattleObject
	object.data = object_data
	object.grid = grid
	object.set_cell(cell)

	battle_objects_parent.add_child(object)
	objects[cell] = object
	
	#occupied[cell] = unit
	#objects_changed.emit()

func get_objects():
	return objects

func is_environment_at(cell: Vector2i) -> bool:
	return objects.has(cell) or is_objective_at(cell)

func is_objective_at(cell: Vector2i) -> bool:
	return cell == objective_cell and objective_hp > 0

func is_objective_alive() -> bool:
	return objective_hp > 0

func damage_environment(cell: Vector2i, amount: int):
	if amount <= 0:
		return

	if is_objective_at(cell):
		damage_objective(amount)
		return

	if not objects.has(cell):
		return

func damage_objective(amount: int):
	if amount <= 0 or objective_hp <= 0:
		return

	objective_hp = max(0, objective_hp - amount)
	objective_updated.emit(objective_hp, objective_max_hp, objective_cell)
	#_recalculate_power_grid()
	_refresh_objective_marker()

	if objective_hp <= 0:
		objective_destroyed.emit(objective_cell)

func get_objective_state() -> Dictionary:
	return {
		"cell": objective_cell,
		"hp": objective_hp,
		"max_hp": objective_max_hp,
		"alive": objective_hp > 0
	}

#func _setup_default_grid_buildings():
	#grid_buildings.clear()
	#grid_buildings[Vector2i(8, 2)] = 2
	#grid_buildings[Vector2i(9, 1)] = 2

#func _recalculate_power_grid():
	#power_grid_max_hp = objective_max_hp
	#power_grid_hp = objective_hp
	#for hp in grid_buildings.values():
		#power_grid_max_hp += 2
		#power_grid_hp += max(0, int(hp))
	#power_grid_updated.emit(power_grid_hp, power_grid_max_hp)

func _refresh_objective_marker():
	if objective_marker == null:
		return
	objective_marker.visible = objective_hp > 0
	if not objective_marker.visible or grid == null:
		return
	var tile := grid.get_tile(objective_cell)
	if tile != null:
		objective_marker.position = tile.position
		objective_marker.z_index = tile.coord.x + tile.coord.y + 1000
		print(objective_marker.z_index)
	
