extends Node2D
class_name SelectionController

@export var camera: Camera2D
@export var grid: Grid

var selected_cell: Vector2i = Vector2i(-1, -1)

func _process(_delta):
	update_selection()

func update_selection():
	var cell: Vector2i = IsoHelper.screen_to_grid(
		camera.get_global_mouse_position() - grid.global_position,
		grid.iso_config
	)
	
	if cell != selected_cell:
		selected_cell = cell
		on_cell_changed(cell)

func on_cell_changed(cell: Vector2i):
	print("Selected cell:", cell)
	grid.highlight_cell(cell)
