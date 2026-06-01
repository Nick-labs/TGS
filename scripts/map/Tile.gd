extends Node2D
class_name Tile

enum Visual {
	REACHABLE,
	ACTION_TARGET,
	HOVER,
	SELECTED
}

@export var dungeon_variants: Array[Texture2D]
@export var forest_spritesheet: Texture2D

func set_dungeon_variant(index: int):
	$Sprite2D.texture = dungeon_variants[index]

func set_forest_variant():
	var variants = slice_tiles(
		forest_spritesheet,
		Vector2i(128, 72)
	)
	
	$Sprite2D.texture = variants.pick_random()

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

func slice_tiles(texture: Texture2D, tile_size: Vector2i) -> Array[Texture2D]:
	var result: Array[Texture2D] = []

	var cols = texture.get_width() / tile_size.x
	var rows = texture.get_height() / tile_size.y

	for y in rows:
		for x in cols:
			var atlas := AtlasTexture.new()

			atlas.atlas = texture
			atlas.region = Rect2(
				x * tile_size.x,
				y * tile_size.y,
				tile_size.x,
				tile_size.y
			)

			result.append(atlas)

	return result
