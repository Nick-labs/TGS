extends Resource
class_name UnitData

@export var display_name: String = "Unit"

@export var max_hp: int = 3
@export var move_range: int = 3
@export var action_cost: int = 1

@export var texture: Texture2D
@export var visual_offset: Vector2 = Vector2.ZERO
@export var visual_scale: Vector2 = Vector2.ONE
@export var modulate: Color = Color.WHITE
