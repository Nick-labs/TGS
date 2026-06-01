class_name EnemyObjectiveComponent
extends ObjectComponent

#signal objective_destroyed(obj: BattleObject, cell: Vector2i)
#
#func on_death(obj: BattleObject):
	#objective_destroyed.emit(obj, obj.cell)
