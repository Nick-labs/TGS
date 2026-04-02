extends Node2D

class_name Grid

@export var width: int = 10
@export var height: int = 10
@export var tile_scene: PackedScene
@export var iso_config: IsoConfig

var tiles: Dictionary = {}

func _ready() -> void:
	generate_grid()
	
func generate_grid() -> void:
	for x in range(width):
		for y in range(height):
			create_tile(Vector2i(x, y))

func create_tile(coord: Vector2i) -> void:
	var tile = tile_scene.instantiate()
	
	tile.coord = coord
	tile.position = IsoHelper.grid_to_screen(Vector2i(coord.x, coord.y), iso_config)
	tile.z_index = coord.x + coord.y
	
	tiles[coord] = tile
	add_child(tile)

func get_tile(coord: Vector2i) -> Tile:
	return tiles.get(coord, null)

func is_in_bounds(coord: Vector2i) -> bool:
	return coord.x >= 0 and coord.x < width and coord.y >= 0 and coord.y < height

func get_neighbors(coord: Vector2i) -> Array:
	var dirs = [
		Vector2i(1,0),
		Vector2i(-1,0),
		Vector2i(0,1),
		Vector2i(0,-1),
		Vector2i(1,1),
		Vector2i(-1,-1),
		Vector2i(1,-1),
		Vector2i(-1,1)
	]

	var result = []

	for d in dirs:
		var n = coord + d
		if is_in_bounds(n):
			result.append(get_tile(n))

	return result

func highlight_cell(cell: Vector2i):
	var tile := get_tile(cell)
	if tile == null:
		return

	$HighlightTile.global_position = tile.global_position
