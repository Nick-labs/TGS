extends Node2D
class_name Unit

signal move_finished(final_cell: Vector2i)

var grid: Grid
var cell: Vector2i
var is_moving := false

func _ready():
	auto_adjust_visual()

func set_cell(new_cell: Vector2i):
	cell = new_cell
	
	update_position()

func update_position():
	if grid == null:
		return

	var tile := grid.get_tile(cell)
	if tile == null:
		return
	
	position = tile.position
	
func auto_adjust_visual():
	var sprite := $Visual/Sprite2D
	if sprite.texture == null:
		return
	
	var height = sprite.texture.get_size().y
	$Visual.position.y = -height / 2.0

func move_directly_to_cell(target_cell: Vector2i):
	if is_moving:
		return

	is_moving = true
	cell = target_cell
	
	var tile := grid.get_tile(cell)
	if tile == null:
		return
	
	var target_pos := tile.position
	
	var tween := create_tween()
	
	tween.tween_property(self, "position", target_pos, 0.25) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
		
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	
	tween.finished.connect(func():
		is_moving = false
	)
	
func move_along_path(path: Array[Vector2i]):
	if is_moving:
		return
	
	is_moving = true
	
	var tween := create_tween()
	
	for i in range(path.size()):
		var path_cell := path[i]
		
		var tile := grid.get_tile(path_cell)
		if tile == null:
			continue
		
		var target := tile.position
		var duration := 0.2
		
		tween.tween_property(self, "position", target, duration)
		
		tween.tween_callback(func(c = path_cell):
			self.cell = c
		)

	tween.finished.connect(func():
		is_moving = false
		move_finished.emit(cell)
	)
