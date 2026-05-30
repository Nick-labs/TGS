extends Node2D
class_name Tile

enum Visual {
	REACHABLE,
	ACTION_TARGET,
	HOVER,
	SELECTED
}

var visual_flags: Array = []

var coord: Vector2i

func add_visual_flag(flag: Visual) -> void:
	visual_flags.append(flag)
	_update_visual()

func remove_visual_flag(flag: Visual) -> void:
	visual_flags.erase(flag)
	_update_visual()

func clear_visual_flags() -> void:
	visual_flags = []
	_update_visual()

func has_visual_flag(flag: Visual) -> bool:
	return flag in visual_flags

func _update_visual() -> void:
	modulate = Color.WHITE

	if has_visual_flag(Visual.REACHABLE):
		modulate = Color(0.0, 0.0, 0.79, 0.678)
	
	if has_visual_flag(Visual.ACTION_TARGET):
		modulate = Color(0.914, 0.0, 0.018, 0.678)
