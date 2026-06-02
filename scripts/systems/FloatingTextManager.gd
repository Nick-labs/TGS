extends Node

@export var damage_text_scene: PackedScene = preload("res://scenes/map/DamageText.tscn")


func show_damage(amount: int, world_pos: Vector2):
	var text = damage_text_scene.instantiate()
	
	text.modulate = Color(1, 0, 0)
	#text.scale = Vector2(2, 2)

	get_tree().current_scene.add_child(text)

	text.position = world_pos
	text.setup(amount)
