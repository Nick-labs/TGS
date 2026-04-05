extends Node2D
class_name SelectionController

@export var camera: Camera2D
@export var grid: Grid
@export var unit_manager: UnitManager
@export var battle_manager: BattleManager

var hovered_cell: Vector2i = Vector2i(-1, -1)
var selected_cell: Vector2i = Vector2i(-1, -1)

func _process(_delta):
	var mouse_world := get_viewport().get_camera_2d().get_global_mouse_position()
	
	var cell := IsoHelper.screen_to_grid(
		mouse_world - grid.global_position,
		grid.iso_config
	)
	
	update_hover(cell)

func update_hover(cell: Vector2i):
	if cell == hovered_cell:
		return

	hovered_cell = cell

	if not grid.is_in_bounds(cell):
		grid.hide_hover()
		return

	grid.show_hover(cell)

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			handle_click()

func handle_click():
	if not grid.is_in_bounds(hovered_cell):
		return
	
	battle_manager.select_at(hovered_cell)
