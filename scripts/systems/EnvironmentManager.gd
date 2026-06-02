extends Node
class_name EnvironmentManager

signal objective_updated(current_hp: int, max_hp: int, cell: Vector2i)
signal objective_destroyed
# signal power_grid_updated(current_hp: int, max_hp: int)

@export var grid: Grid

#var units: Array[Unit] = []

var objects: Dictionary = {}

@export var battle_object_scene: PackedScene
@export var battle_objects_parent: Node2D

#var grid_buildings: Dictionary = {}
var power_grid_hp: int = 0
var power_grid_max_hp: int = 0

func _ready():
	reset_state()

func reset_state():
	objects.clear()
	#_refresh_objective_marker()
	#objective_updated.emit(objective_hp, objective_max_hp, objective_cell)

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
	
	object.died.connect(_on_obj_died)
	
	#occupied[cell] = unit
	#objects_changed.emit()

func get_objects():
	return objects

func get_obj_at(cell: Vector2i) -> BattleObject:
	return objects.get(cell)

func is_environment_at(cell: Vector2i) -> bool:
	return objects.has(cell) or is_objective_at(cell)

func is_objective_at(cell: Vector2i) -> bool:
	var obj: BattleObject = objects.get(cell)
	
	if obj == null:
		return false
	
	if not obj.get_component(EnemyObjectiveComponent):
		return false
	
	return true

#func is_objective_alive() -> bool:
	#return objective_hp > 0

func damage_env_obj(obj: BattleObject, damage: int):
	if obj == null or damage <= 0:
		return
	
	obj.take_damage(damage)
	
	#_recalculate_power_grid()

func is_objective_alive() -> bool:
	for obj in objects.values():
		if obj.get_component(EnemyObjectiveComponent):
			return true
			
	return false

#func _recalculate_power_grid():
	#power_grid_max_hp = objective_max_hp
	#power_grid_hp = objective_hp
	#for hp in grid_buildings.values():
		#power_grid_max_hp += 2
		#power_grid_hp += max(0, int(hp))
	#power_grid_updated.emit(power_grid_hp, power_grid_max_hp)

func _on_obj_died(obj: BattleObject):
	if obj.get_component(EnemyObjectiveComponent):
		objective_destroyed.emit()
	
	objects.erase(obj.cell)

func get_objectives() -> Array[BattleObject]:
	var objectives: Array[BattleObject] = []
	for object in objects.values():
		if object.has_component(EnemyObjectiveComponent):
			objectives.append(object)
	
	return objectives
