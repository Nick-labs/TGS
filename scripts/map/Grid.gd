extends Node2D
class_name Grid

@export var width: int = 10
@export var height: int = 10
@export var tile_scene: PackedScene
@export var iso_config: IsoConfig
@export var unit_manager: UnitManager
@export var env_manager: EnvironmentManager

var terrain: TerrainData

var tiles: Dictionary = {}
var astar := AStarGrid2D.new()

func _ready() -> void:
	pass

func setup(grid_size: Vector2i, terrain_data: TerrainData):
	width = grid_size.x
	height = grid_size.y
	terrain = terrain_data
	generate_grid(grid_size)
	setup_astar()

func generate_grid(size: Vector2i) -> void:
	for x in range(size.x):
		for y in range(size.y):
			create_tile(Vector2i(x, y))

func create_tile(coord: Vector2i) -> void:
	var tile = tile_scene.instantiate()
	#tile.set_dungeon_variant(randi_range(0, 1))
	
	tile.coord = coord
	tile.position = IsoHelper.grid_to_screen(coord, iso_config)
	tile.z_index = coord.x + coord.y
	
	var variants = terrain.tile_variants
	if not variants.is_empty():
		tile.set_sprite(variants.pick_random(), )
	
	tiles[coord] = tile
	add_child(tile)

func get_tile(coord: Vector2i) -> Tile:
	return tiles.get(coord)

func is_in_bounds(coord: Vector2i) -> bool:
	return coord.x >= 0 and coord.x < width and coord.y >= 0 and coord.y < height

func get_neighbor_coords(coord: Vector2i) -> Array[Vector2i]:
	var dirs = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
	var result: Array[Vector2i] = []
	
	for dir in dirs:
		var n = coord + dir
		if is_in_bounds(n):
			result.append(n)
			
	return result

func get_bounds() -> Rect2:
	if tiles.is_empty():
		return Rect2()
	
	var min_pos: Vector2 = Vector2(INF, INF)
	var max_pos: Vector2 = Vector2(-INF, -INF)
	
	for tile in tiles.values():
		var pos: Vector2 = tile.position
		min_pos.x = min(min_pos.x, pos.x)
		min_pos.y = min(min_pos.y, pos.y)
		max_pos.x = max(max_pos.x, pos.x)
		max_pos.y = max(max_pos.y, pos.y)
		
	return Rect2(min_pos, max_pos - min_pos)

func show_hover(cell: Vector2i):
	var tile := get_tile(cell)
	
	if tile == null:
		return
	
	$HoverHighlight.visible = true
	$HoverHighlight.position = tile.position
	$HoverHighlight.z_index = tile.coord.x + tile.coord.y + 1

func hide_hover():
	$HoverHighlight.visible = false

func show_selected(cell: Vector2i):
	var tile := get_tile(cell)
	
	if tile == null:
		return
		
	$SelectedHighlight.visible = true
	$SelectedHighlight.position = tile.position
	$SelectedHighlight.z_index = tile.coord.x + tile.coord.y + 2

func hide_selected():
	$SelectedHighlight.visible = false

func set_visual_flag_to_cells(cells: Array[Vector2i], visual_flag: Tile.Visual):
	for cell in cells:
		var tile := get_tile(cell)
		
		if tile == null:
			continue
			
		tile.add_visual_flag(visual_flag)

#func show_action_targets(cells: Array[Vector2i]):
	#for cell in cells:
		#var tile := get_tile(cell)
		#if tile == null:
			#continue
		#tile.set_state(Tile.State.ACTION_TARGET)

func remove_visual_flag_from_all_cells(visual_flag: Tile.Visual):
	for tile in tiles.values():
		if tile != null:
			tile.remove_visual_flag(visual_flag)

func remove_all_visual_flags_from_tiles():
	for tile in tiles.values():
		if tile != null:
			tile.clear_visual_flags()

func setup_astar():
	astar.region = Rect2i(Vector2i(0, 0), Vector2i(width, height))
	astar.cell_size = Vector2(1, 1)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()

func find_path(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	if not is_in_bounds(from) or not is_in_bounds(to):
		return []
		
	_clear_astar_solids()
	_apply_occupied_to_astar(from, to)
	
	var path := astar.get_id_path(from, to)
	var result: Array[Vector2i] = []
	
	for p in path:
		result.append(Vector2i(p))
		
	return result

func _clear_astar_solids():
	for x in range(width):
		for y in range(height):
			astar.set_point_solid(Vector2i(x, y), false)

func _apply_occupied_to_astar(from: Vector2i, to: Vector2i):
	for cell in unit_manager.occupied.keys():
		if cell == from or cell == to:
			continue
		astar.set_point_solid(cell, true)
	
	for object_cell in env_manager.objects:
		#if object.is_solid:
			#astar.set_point_solid(object.cell, true)
		astar.set_point_solid(object_cell, true)

func get_entity(cell: Vector2i) -> Entity:
	var unit = unit_manager.get_unit(cell)
	if unit:
		return unit
	
	var object = env_manager.get_obj_at(cell)
	if object:
		return object
	
	return null
