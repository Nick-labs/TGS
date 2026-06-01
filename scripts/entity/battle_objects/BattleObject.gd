extends Entity
class_name BattleObject

signal health_changed(unit: Unit, old_hp: int, new_hp: int)
signal died(unit: Unit)
signal death_animation_finished(unit: Unit)


var grid: Grid

var data: ObjectData

@onready var sprite: Sprite2D = $Visual/NoObjectSprite
@export var visual_offset: Vector2 = Vector2.ZERO

var max_hp: int
var hp: int

var components: Array[ObjectComponent] = []

var _hit_flash_tween: Tween
var _attack_tween: Tween
var _death_tween: Tween


func initialize(object_data: ObjectData):
	data = object_data

	sprite.texture = data.sprite

	for component in data.components:
		var instance = component.duplicate(true)

		components.append(instance)

		instance.on_added(self)

	visual_offset = data.visual_offset
	$Visual.scale = data.visual_scale

	auto_adjust_visual()
	
func get_component(component_type):
	for component in components:
		if is_instance_of(component, component_type):
			return component
	return null

func take_damage(amount, source = null):
	var health = get_component(HealthComponent)
	
	if health == null:
		return

	health.hp -= amount

	for component in components:
		component.on_damage(
			self,
			amount,
			source
		)

	if health.hp <= 0:
		die()

func die():
	for component in components:
		component.on_death(self)
	queue_free()



func _ready():
	if data == null:
		push_error("UnitData is missing on %s" % name)
		return
		
	#hp = data.max_hp
	
	sprite.centered = false
	
	initialize(data)
	
	update_z_index()

func _process(delta):
	update_z_index() # TODO: optimize
	
func _draw():
	draw_circle(Vector2.ZERO, 3, Color.RED)

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

func auto_adjust_visual():
	if sprite.texture == null:
		return

	var size = sprite.texture.get_size() * $Visual.scale
	
	$Visual.position = Vector2(
		-size.x / 2.0,
		-size.y
	) + visual_offset

#func take_damage(amount: int):
	#if amount <= 0:
		#return
	#var old_hp := hp
	#hp = max(0, hp - amount)
	#health_changed.emit(self, old_hp, hp)
	#play_hit_flash()
	#if hp <= 0:
		#died.emit(self)

func is_dead() -> bool:
	return hp <= 0

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
