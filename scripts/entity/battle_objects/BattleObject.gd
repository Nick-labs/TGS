extends Entity
class_name BattleObject

@export var data: ObjectData

var components: Array[ObjectComponent] = []

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
