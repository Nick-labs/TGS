extends Node2D
class_name Unit

signal move_finished(final_cell: Vector2i)
signal health_changed(unit: Unit, old_hp: int, new_hp: int)
signal died(unit: Unit)

enum Team {
	PLAYER,
	ENEMY
}

var unit_data = {
	Team.PLAYER: {
		"texture": preload("res://assets/sprites/units/TestUnit.png"),
		"offset": Vector2(0, 0),
		"scale": Vector2(1, 1)
	},
	Team.ENEMY: {
		"texture": preload("res://assets/sprites/units/EnemyUnit.png"),
		"offset": Vector2(10, 0),
		"scale": Vector2(2, 2)
	}
}

@onready var sprite: Sprite2D = $Visual/Sprite2D
@export var visual_offset: Vector2 = Vector2.ZERO

@export var team: Team = Team.PLAYER:
	set(value):
		if team == value:
			return
		team = value
		
		if is_inside_tree():
			update_sprite()

@export var move_range: int = 3
@export var max_hp: int = 3
@export var action: BaseAction
@export var action_cost: int = 1

var grid: Grid
var cell: Vector2i
var is_moving := false
var hp: int = max_hp
var has_moved_this_turn := false
var has_acted_this_turn := false
var _hit_flash_tween: Tween

func _ready():
	hp = max_hp
	
	# важно для корректного позиционирования
	sprite.centered = false
	
	update_sprite()

func _draw():
	draw_circle(Vector2.ZERO, 3, Color.RED)

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

func update_sprite():
	var data = unit_data.get(team)
	if data == null:
		return

	sprite.texture = data.texture
	visual_offset = data.offset
	$Visual.scale = data.scale
	
	auto_adjust_visual()

func auto_adjust_visual():
	if sprite.texture == null:
		return

	var size = sprite.texture.get_size() * $Visual.scale
	
	$Visual.position = Vector2(
		-size.x / 2.0,
		-size.y
	) + visual_offset

func move_along_path(path: Array[Vector2i]):
	if is_moving:
		return

	is_moving = true
	var tween := create_tween()

	for path_cell in path:
		var tile := grid.get_tile(path_cell)
		if tile == null:
			continue

		tween.tween_property(self, "position", tile.position, 0.2)
		tween.tween_callback(func(c = path_cell):
			self.cell = c
		)

	tween.finished.connect(func():
		is_moving = false
		has_moved_this_turn = true
		move_finished.emit(cell)
	)

func can_move_this_turn() -> bool:
	return (not has_moved_this_turn) and (not is_moving)

func can_act_this_turn() -> bool:
	return not has_acted_this_turn

func reset_turn_flags():
	has_moved_this_turn = false
	has_acted_this_turn = false

func take_damage(amount: int):
	if amount <= 0:
		return
	
	var old_hp := hp
	hp = max(0, hp - amount)
	
	health_changed.emit(self, old_hp, hp)
	play_hit_flash()
	
	if hp <= 0:
		died.emit(self)

func is_dead() -> bool:
	return hp <= 0

func get_team_label() -> String:
	return "ALLY" if team == Team.PLAYER else "ENEMY"

func play_hit_flash():
	if sprite == null:
		return

	if _hit_flash_tween != null:
		_hit_flash_tween.kill()

	sprite.modulate = Color(2.0, 2.0, 2.0, 1.0)

	_hit_flash_tween = create_tween()
	_hit_flash_tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.12)
