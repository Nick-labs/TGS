extends Node2D
class_name Unit

signal move_finished(final_cell: Vector2i)
signal health_changed(unit: Unit, old_hp: int, new_hp: int)
signal died(unit: Unit)
signal death_animation_finished(unit: Unit)

enum Team {
	PLAYER,
	ENEMY
}

@onready var sprite: Sprite2D = $Visual/NoUnitSprite
@export var visual_offset: Vector2 = Vector2.ZERO

@export var team: Team = Team.PLAYER:
	set(value):
		if team == value:
			return
		team = value
		
		#if is_inside_tree():
			#update_sprite()

@export var data: UnitData

var max_hp: int
var move_range: int
var action_cost: int
var actions: Array[BattleAction]
var default_action: BattleAction

var grid: Grid
var cell: Vector2i
var is_moving := false
var hp: int
var has_moved_this_turn := false
var has_acted_this_turn := false
var _hit_flash_tween: Tween
var _attack_tween: Tween
var _death_tween: Tween

func _ready():
	if data == null:
		push_error("UnitData is missing on %s" % name)
		return
		
	hp = data.max_hp
	move_range = data.move_range
	actions = data.actions.duplicate()
	default_action = actions[0]
	action_cost = data.action_cost
	
	sprite.centered = false
	
	apply_data()
	
	update_z_index()

func _process(delta):
	update_z_index()
	
func _draw():
	draw_circle(Vector2.ZERO, 3, Color.RED)

func update_z_index():
	z_index = (cell.x + cell.y) * 1000

func set_cell(new_cell: Vector2i):
	cell = new_cell
	update_position()
	update_z_index()

func update_position():
	if grid == null:
		return

	var tile := grid.get_tile(cell)
	if tile == null:
		return

	position = tile.position

func apply_data():
	sprite.texture = data.texture
	#sprite.modulate = data.modulate

	visual_offset = data.visual_offset

	$Visual.scale = data.visual_scale

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
	
	#z_index = cell.x + cell.y - 5
	
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

func play_attack_lunge(target_cell: Vector2i):
	if is_moving:
		return
	if _death_tween != null:
		return
	if grid == null:
		return
	var tile := grid.get_tile(target_cell)
	if tile == null:
		return
	if _attack_tween != null:
		_attack_tween.kill()
	var start_pos := position
	var dir := (tile.position - start_pos).normalized()
	var lunge_pos := start_pos + dir * 10.0
	_attack_tween = create_tween()
	_attack_tween.tween_property(self, "position", lunge_pos, 0.06)
	_attack_tween.tween_property(self, "position", start_pos, 0.09)

func play_hit_flash():
	var sprite: Sprite2D = $Visual/Sprite2D
	if sprite == null:
		return

	if _hit_flash_tween != null:
		_hit_flash_tween.kill()

	sprite.modulate = Color(2.2, 2.2, 2.2, 1.0)
	_hit_flash_tween = create_tween()
	_hit_flash_tween.tween_property(sprite, "modulate", Color(1.55, 1.55, 1.55, 1), 0.08)
	_hit_flash_tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.16)

func play_death_animation():
	if _death_tween != null:
		return
	var sprite: Sprite2D = $Visual/Sprite2D
	if sprite == null:
		death_animation_finished.emit(self)
		return
	if _attack_tween != null:
		_attack_tween.kill()
	if _hit_flash_tween != null:
		_hit_flash_tween.kill()
	_death_tween = create_tween()
	_death_tween.tween_property(sprite, "modulate:a", 0.0, 0.16)
	_death_tween.parallel().tween_property($Visual, "scale", Vector2(0.7, 0.7), 0.16)
	_death_tween.finished.connect(func():
		death_animation_finished.emit(self)
	)
