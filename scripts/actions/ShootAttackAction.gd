extends BattleAction
class_name ArtilleryAttackAction

@export var min_range: int = 2
@export var max_range: int = 4

func _init():
	name = "artillery_attack"
	display_name = "Shoot"
	damage = 1
	range = max_range
	cost = 1
	attack_sound = preload(
		"res://assets/audio/attacks/bow_attack_sfx.mp3"
	)

func get_target_cells(unit: Unit, grid: Grid, _unit_manager: UnitManager) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for x in range(grid.width):
		for y in range(grid.height):
			var cell := Vector2i(x, y)
			var dist := int(unit.cell.distance_to(cell))
			if dist < min_range or dist > max_range:
				continue
			result.append(cell)
	return result

func build_effects(unit: Unit, target_cell: Vector2i, _grid: Grid, _unit_manager: UnitManager) -> Array[Dictionary]:
	var dist := int(unit.cell.distance_to(target_cell))
	if dist < min_range or dist > max_range:
		return []

	return [
		{
			"type": "damage",
			"target_cell": target_cell,
			"amount": damage,
			"source": unit
		}
	]
