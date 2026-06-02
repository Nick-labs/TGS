extends BattleAction
class_name BiteAttackAction

func _init():
	name = "bite_attack"
	damage = 1
	range = 1
	cost = 1
	attack_sound = preload(
		"res://assets/audio/attacks/default_attack_2_sfx.mp3"
	)

func get_target_cells(unit: Unit, grid: Grid, _unit_manager: UnitManager) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for n in grid.get_neighbor_coords(unit.cell):
		result.append(n)
	return result

func build_effects(unit: Unit, target_cell: Vector2i, grid: Grid, _unit_manager: UnitManager) -> Array[Dictionary]:
	if target_cell not in grid.get_neighbor_coords(unit.cell):
		return []

	return [
		{
			"type": "damage",
			"target_cell": target_cell,
			"amount": damage,
			"source": unit
		}
	]
