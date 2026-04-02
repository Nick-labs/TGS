extends Object
class_name IsoHelper


const TILE_WIDTH = 128
const TILE_HEIGHT = 64


static func grid_to_screen(grid_pos: Vector2i) -> Vector2:
	var x = grid_pos.x
	var y = grid_pos.y

	var screen_x = (x - y) * TILE_WIDTH * 0.5
	var screen_y = (x + y) * TILE_HEIGHT * 0.5

	return Vector2(screen_x, screen_y)

static func screen_to_grid(screen_pos: Vector2) -> Vector2i:
	var x = screen_pos.x
	var y = screen_pos.y

	var grid_x = (x / TILE_WIDTH + y / TILE_HEIGHT) * 0.5
	var grid_y = (y / TILE_HEIGHT - x / TILE_WIDTH) * 0.5

	return Vector2i(floor(grid_x), floor(grid_y))
