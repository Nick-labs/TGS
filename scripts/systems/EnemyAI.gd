extends Node
class_name EnemyAI

@export var grid: Grid
@export var unit_manager: UnitManager
@export var objective_focus_radius: int = 6
@export var env_manager: EnvironmentManager

func plan_enemy_turn(
	enemy_units: Array[Unit],
	player_units: Array[Unit],
	#objective_state: Dictionary,
	threat_level: int,
	focus_threshold: int
) -> Array[Dictionary]:
	
	var plans: Array[Dictionary] = []
	for enemy in enemy_units:
		if enemy == null or not is_instance_valid(enemy) or enemy.is_dead():
			continue
			
		var plan := _build_plan_for_enemy(enemy,
		env_manager.get_objectives(),
		player_units,
		threat_level, focus_threshold)
		
		plans.append(plan)
	return plans

func _build_plan_for_enemy(
	enemy: Unit,
	objectives: Array[BattleObject],
	player_units: Array[Unit],
	threat_level: int,
	focus_threshold: int
) -> Dictionary:
	
	var target_cell := enemy.cell
	var target_mode := "idle"
	
	if _should_focus_objective(
		enemy,
		objectives,
		player_units,
		threat_level,
		focus_threshold
	):
		var objective := objectives[0]

		var attack_cells := _get_attack_positions(objective.cell)

		if attack_cells.is_empty():
			target_cell = enemy.cell
			target_mode = "objective"
		else:
			target_cell = _pick_best_attack_position(enemy, attack_cells)
			target_mode = "objective"
	
	else:
		var target_player := _pick_target_player(enemy, player_units)
		
		if target_player == null:
			return {}

		target_cell = target_player.cell
		target_mode = "player"
	
	var move_to := _pick_move_cell(enemy, target_cell)
	var action_target := _pick_action_target(enemy, move_to, target_cell, target_mode)

	var preview := _build_preview_cells(action_target)
	
	var path := grid.find_path(enemy.cell, target_cell)
	
	return {
		"unit": enemy,
		"move_to": move_to,
		"action": enemy.default_action,
		"target_cell": action_target,
		"preview_cells": preview,
		"target_mode": target_mode
	}

func _get_attack_positions(cell: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	for n in grid.get_neighbor_coords(cell):
		if grid.is_in_bounds(n) and not unit_manager.is_occupied(n):
			result.append(n)

	return result

func _pick_best_attack_position(enemy: Unit, positions: Array[Vector2i]) -> Vector2i:
	var best := enemy.cell
	var best_dist := INF

	for p in positions:
		var d := enemy.cell.distance_to(p)
		if d < best_dist:
			best = p
			best_dist = d

	return best

func _pick_target_player(enemy: Unit, player_units: Array[Unit]) -> Unit:
	#if enemy.archetype == Unit.Archetype.SNIPER:
		#return _find_farthest(enemy, player_units)
	return _find_closest(enemy, player_units)

func _pick_action_target(enemy: Unit, move_to: Vector2i, preferred_target: Vector2i, target_mode: String) -> Vector2i:
	if enemy.default_action == null:
		return move_to

	var candidates: Array[Vector2i] = []
	var original_cell := enemy.cell
	enemy.cell = move_to
	var raw_targets: Array[Vector2i] = enemy.default_action.get_target_cells(enemy, grid, unit_manager)
	for c in raw_targets:
		if grid.is_in_bounds(c):
			candidates.append(c)
	enemy.cell = original_cell

	if candidates.is_empty():
		if target_mode == "objective":
			return preferred_target
		return move_to

	var best := candidates[0]
	var best_dist := best.distance_to(preferred_target)
	for c in candidates:
		var d := c.distance_to(preferred_target)
		if d < best_dist:
			best = c
			best_dist = d
	return best

func _should_focus_objective(
	enemy: Unit,
	objectives,
	player_units: Array[Unit],
	threat_level: int,
	focus_threshold: int
) -> bool:
	
	if objectives.is_empty():
		return false
	
	var objective = objectives[0]
	
	if objective == null:
		return false
	
	if threat_level < focus_threshold:
		return false

	var objective_dist := int(enemy.cell.distance_to(objective.cell))
	
	if objective_dist > objective_focus_radius:
		return false

	if player_units.is_empty():
		return true

	var closest_player := _find_closest(enemy, player_units)
	
	var player_dist := int(enemy.cell.distance_to(closest_player.cell))
	
	return objective_dist <= player_dist + 2

func _pick_move_cell(enemy: Unit, target_cell: Vector2i) -> Vector2i:
	var path := grid.find_path(enemy.cell, target_cell)
	if path.size() <= 1:
		return enemy.cell

	var max_step = min(enemy.move_range, path.size() - 1)
	
	if max_step <= 0:
		return enemy.cell

	var best := enemy.cell
	for step in range(1, max_step + 1):
		var candidate := path[step]
		if unit_manager.is_occupied(candidate) and candidate != enemy.cell:
			break
		best = candidate

	return best

func _build_preview_cells(target_cell: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	if grid.is_in_bounds(target_cell):
		result.append(target_cell)
	return result

func _find_closest(from_unit: Unit, units: Array[Unit]) -> Unit:
	if units.is_empty():
		return
	var best := units[0]
	var best_dist := from_unit.cell.distance_to(best.cell)
	for u in units:
		if u == null or not is_instance_valid(u) or u.is_dead():
			continue
		var d := from_unit.cell.distance_to(u.cell)
		if d < best_dist:
			best = u
			best_dist = d
	return best

func _find_farthest(from_unit: Unit, units: Array[Unit]) -> Unit:
	var best := units[0]
	var best_dist := from_unit.cell.distance_to(best.cell)
	for u in units:
		if u == null or not is_instance_valid(u) or u.is_dead():
			continue
		var d := from_unit.cell.distance_to(u.cell)
		if d > best_dist:
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
