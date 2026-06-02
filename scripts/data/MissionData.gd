extends Resource
class_name MissionData

@export var grid_size: Vector2i = Vector2i(10, 10)
@export var cp_max: int = 3
@export var threat_growth_per_turn: int = 1
@export var unit_spawns: Array[UnitSpawnData]
@export var battle_object_spawns: Array[BattleObjectSpawnData]
@export var terrain: TerrainData
# @export var has_enemy_objective: bool = false
