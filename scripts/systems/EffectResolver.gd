extends Node
class_name EffectResolver

@export var grid: Grid
@export var unit_manager: UnitManager
@export var environment_manager: EnvironmentManager

func resolve_effects(effects: Array[Dictionary]):
	var queue: Array[Dictionary] = effects.duplicate(true)

	while not queue.is_empty():
		var effect := queue.pop_front()
		var type := effect.get("type", "")

		match type:
			"damage":
				_resolve_damage(effect)
			"push":
				var chained := _resolve_push(effect)
				for c in chained:
					queue.append(c)

func _resolve_damage(effect: Dictionary):
	var cell: Vector2i = effect.get("target_cell", Vector2i(-1, -1))
	var amount: int = effect.get("amount", 0)
	if amount <= 0:
		return

	var target := unit_manager.get_unit_at(cell)
	if target != null:
		target.take_damage(amount)
		if target.is_dead():
			unit_manager.remove_unit(target)
		return

	if environment_manager != null:
		environment_manager.damage_environment(cell, amount)

func _resolve_push(effect: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var cell: Vector2i = effect.get("target_cell", Vector2i(-1, -1))
	var dir: Vector2i = effect.get("direction", Vector2i.ZERO)
	var distance: int = max(1, effect.get("distance", 1))
	var target := unit_manager.get_unit_at(cell)

	if target == null:
		return result

	for _i in range(distance):
		var next_cell := target.cell + dir
		if not grid.is_in_bounds(next_cell):
			result.append({"type": "damage", "target_cell": target.cell, "amount": 1})
			break

		if unit_manager.is_occupied(next_cell):
			result.append({"type": "damage", "target_cell": target.cell, "amount": 1})
			result.append({"type": "damage", "target_cell": next_cell, "amount": 1})
			break

		var old_cell := target.cell
		target.set_cell(next_cell)
		unit_manager.on_unit_moved(target, old_cell, next_cell)

		if environment_manager != null and environment_manager.is_environment_at(next_cell):
			result.append({"type": "damage", "target_cell": next_cell, "amount": 1})

	return result
