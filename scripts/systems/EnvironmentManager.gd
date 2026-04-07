extends Node
class_name EnvironmentManager

var objects: Dictionary = {}

func is_environment_at(cell: Vector2i) -> bool:
	return objects.has(cell)

func damage_environment(cell: Vector2i, amount: int):
	if not objects.has(cell):
		return

	objects[cell] -= amount
	if objects[cell] <= 0:
		objects.erase(cell)
