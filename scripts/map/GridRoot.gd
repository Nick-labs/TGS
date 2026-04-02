extends Node2D
class_name GridRoot

@export var camera: Camera2D
@export var grid: Grid

@export var padding_percent := 0.1

func _ready() -> void:
	call_deferred("fit_grid_to_screen")

func fit_grid_to_screen() -> void:
	if grid == null:
		return

	var viewport_size := get_viewport_rect().size

	var available_size := viewport_size * (1.0 - padding_percent * 2.0)

	var iso_config = grid.iso_config

	var grid_width_px: float = (grid.width + grid.height) * float(iso_config.tile_width) * 0.5
	var grid_height_px: float = (grid.width + grid.height) * float(iso_config.tile_height) * 0.5

	var scale_x := available_size.x / grid_width_px
	var scale_y := available_size.y / grid_height_px

	var scale: float = min(scale_x, scale_y)

	grid.scale = Vector2(scale, scale)

	center_grid()

func center_grid() -> void:
	var center := Vector2(
		(grid.width - 1) / 2.0,
		(grid.height - 1) / 2.0
	)

	var center_screen := IsoHelper.grid_to_screen(
		Vector2i(center),
		grid.iso_config
	)

	camera.global_position = grid.to_global(center_screen)
