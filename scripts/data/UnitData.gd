extends Resource
class_name UnitData

@export var name: String = "Unit"

@export var max_hp: int = 1
@export var move_range: int = 2
@export var action_cost: int = 1

@export var texture: Texture2D
@export var visual_offset: Vector2 = Vector2.ZERO
@export var visual_scale: Vector2 = Vector2.ONE

@export var actions: Array[BattleAction]
