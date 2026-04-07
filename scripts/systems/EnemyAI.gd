extends Node
class_name EnemyAI

@export var grid: Grid
@export var unit_manager: UnitManager

func plan_enemy_turn(enemy_units: Array[Unit], player_units: Array[Unit]) -> Array[Dictionary]:
	var plans: Array[Dictionary] = []
	for enemy in enemy_units:
		var plan := _build_plan_for_enemy(enemy, player_units)
		plans.append(plan)
	return plans

func _build_plan_for_enemy(enemy: Unit, player_units: Array[Unit]) -> Dictionary:
	if player_units.is_empty():
		return {
			"unit": enemy,
			"move_to": enemy.cell,
			"action": enemy.action,
			"target_cell": enemy.cell,
			"preview_cells": []
		}

	var target := _find_closest(enemy, player_units)
	var move_to := enemy.cell
	var target_cell := target.cell

	if target.cell not in grid.get_neighbor_coords(enemy.cell):
		var path := grid.find_path(enemy.cell, target.cell)
		if path.size() > 1:
			var steps := min(enemy.move_range, path.size() - 1)
			move_to = path[steps]

	if target.cell not in grid.get_neighbor_coords(move_to):
		target_cell = move_to + _best_step_towards(move_to, target.cell)

	var preview := _build_preview_cells(target_cell)

	return {
		"unit": enemy,
		"move_to": move_to,
		"action": enemy.action,
		"target_cell": target_cell,
		"preview_cells": preview
	}

func _build_preview_cells(target_cell: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	if grid.is_in_bounds(target_cell):
		result.append(target_cell)
	return result

func _find_closest(from_unit: Unit, units: Array[Unit]) -> Unit:
	var best := units[0]
	var best_dist := from_unit.cell.distance_to(best.cell)
	for u in units:
		var d := from_unit.cell.distance_to(u.cell)
		if d < best_dist:
			best = u
			best_dist = d
	return best

func _best_step_towards(from_cell: Vector2i, to_cell: Vector2i) -> Vector2i:
	var dir := to_cell - from_cell
	if abs(dir.x) > abs(dir.y):
		return Vector2i(signi(dir.x), 0)
	if dir.y != 0:
		return Vector2i(0, signi(dir.y))
	return Vector2i.ZERO
