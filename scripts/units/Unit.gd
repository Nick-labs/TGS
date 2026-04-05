extends Node2D
class_name Unit

var grid: Grid
var cell: Vector2i

func _ready():
	auto_adjust_visual()
	update_visual()

func set_cell(new_cell: Vector2i):
	cell = new_cell

	update_position()
	update_visual()

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

func update_visual():
	z_index = cell.x + cell.y
	print(z_index)
