extends Object
class_name IsoHelper

static func grid_to_screen(grid_pos: Vector2i, iso_config: IsoConfig) -> Vector2:
	var x = grid_pos.x
	var y = grid_pos.y

	var screen_x = (x - y) * iso_config.tile_width * 0.5
	var screen_y = (x + y) * iso_config.tile_height * 0.5

	return Vector2(screen_x, screen_y)

static func screen_to_grid(screen_pos: Vector2, iso_config: IsoConfig) -> Vector2i:
	var x = screen_pos.x
	var y = screen_pos.y

	var grid_x = (x / iso_config.tile_width + y / iso_config.tile_height) * 0.5
	var grid_y = (y / iso_config.tile_height - x / iso_config.tile_width) * 0.5

	return Vector2i(floor(grid_x), floor(grid_y))
