extends ObjectComponent
class_name ExplodeOnDeathComponent

@export var radius := 1
@export var damage := 1

func on_death(owner):
	pass
	#var cells = BattleGrid.get_cells_in_radius(
		#owner.coord,
		#radius
	#)

	#for cell in cells:
#
		#var entity = BattleGrid.get_entity(cell)
#
		#if entity:
			#entity.take_damage(damage)
