extends Resource
class_name BattleAction

@export var name: String
@export var range: int
@export var damage: int
@export var cost: int = 1
@export var attack_sound: AudioStream

func get_target_cells(_unit: Unit, _grid: Grid, _unit_manager: UnitManager) -> Array[Vector2i]:
	return []

func build_effects(_unit: Unit, _target_cell: Vector2i, _grid: Grid, _unit_manager: UnitManager) -> Array[Dictionary]:
	return []

func preview_cells(unit: Unit, target_cell: Vector2i, grid: Grid, unit_manager: UnitManager) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for effect in build_effects(unit, target_cell, grid, unit_manager):
		if effect.has("target_cell"):
			cells.append(effect["target_cell"])
	return cells
