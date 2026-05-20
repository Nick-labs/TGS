extends Resource
class_name MissionData

@export var objective_cell: Vector2i
@export var objective_max_hp: int = 5
@export var cp_max: int = 3
@export var threat_growth_per_turn: int = 1
@export var unit_spawns: Array[UnitSpawnData]
