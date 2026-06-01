class_name Entity
extends Node2D


var cell: Vector2i
var effects: Array[Effect]

#func take_damage(amount: int):
	#hp -= amount
	#
	#if hp <= 0:
		#die()
#
#func die():
	#queue_free()

func update_z_index():
	z_index = cell.x + cell.y + 1000 # 1000 is entity layer

func die():
	# ...
	for effect in effects:
		effect.on_death()
	# ...
