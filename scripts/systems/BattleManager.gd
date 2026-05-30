extends Node
class_name BattleManager

signal player_action_committed(unit: Unit, target_cell: Vector2i, action_id: String)
signal player_action_denied(unit: Unit, reason: String)
signal player_unit_selected(unit: Unit)
signal player_unit_unselected

@export var unit_manager: UnitManager
@export var turn_manager: TurnManager
@export var environment_manager: EnvironmentManager
@export var movement_system: MovementSystem
@export var effect_resolver: EffectResolver
@export var grid: Grid

@export var action_bar: ActionBar

var selected_action: BattleAction = null

enum BattleState {
	IDLE,
	UNIT_SELECTED,
	UNIT_MOVING,
	ACTION_TARGETING
}

var state: BattleState = BattleState.IDLE
var selected_unit: Unit = null
var reachable_cells: Array[Vector2i] = []
var action_cells: Array[Vector2i] = []

func _ready():
	if action_bar != null:
		action_bar.action_selected.connect(_on_action_selected)

func select_at(cell: Vector2i):
	var clicked_unit := unit_manager.get_unit_at(cell)
	
	if turn_manager != null and not turn_manager.can_accept_player_input():
		return	
	
	match state:
		BattleState.IDLE:
			_handle_idle_click(cell, clicked_unit)

		BattleState.UNIT_SELECTED:
			_handle_unit_selected_click(cell, clicked_unit)

		BattleState.ACTION_TARGETING:
			_handle_action_click(cell, clicked_unit)

func _handle_idle_click(cell, clicked_unit):
	if clicked_unit == null:
		return

	if clicked_unit.team != Unit.Team.PLAYER:
		return

	select_unit(clicked_unit)

func _handle_unit_selected_click(cell, clicked_unit):
	if clicked_unit != null and clicked_unit.team == Unit.Team.PLAYER:
		if clicked_unit != selected_unit:
			select_unit(clicked_unit)
		return

	if cell in reachable_cells:
		try_move_command(cell)
		return

	unselect()

func _handle_action_click(cell, clicked_unit):
	if cell in action_cells:
		try_action_command(cell)
		return

	if clicked_unit != null and clicked_unit.team == Unit.Team.PLAYER:
		select_unit(clicked_unit)
		return

	unselect()

func select_unit(unit: Unit):
	selected_action = null
	action_cells.clear()
	
	grid.remove_visual_flag_from_all_cells(Tile.Visual.REACHABLE)
	grid.remove_visual_flag_from_all_cells(Tile.Visual.ACTION_TARGET)
	
	if unit.team != Unit.Team.PLAYER:
		return
	#if unit.has_moved_this_turn and unit.has_acted_this_turn:
		#return
	
	#print("Selected %s" % unit)
	selected_unit = unit
	player_unit_selected.emit(unit)
	state = BattleState.UNIT_SELECTED
	
	if action_bar != null:
		action_bar.show_unit_actions(unit)
	
	refresh_selection()

func refresh_selection():
	update_movement_visual()
	update_action_visual()

func unselect():
	selected_unit = null
	reachable_cells.clear()
	action_cells.clear()
	state = BattleState.IDLE
	grid.remove_visual_flag_from_all_cells(Tile.Visual.REACHABLE)
	
	player_unit_unselected.emit()
	
	if action_bar != null:
		action_bar.show_unit_actions(null)
	
	#if turn_manager != null:
		#turn_manager.refresh_enemy_intents_visuals()

func try_move_command(cell: Vector2i) -> bool:
	if selected_unit == null:
		return false
	if not movement_system.can_move_to(selected_unit, cell):
		return false
	if state != BattleState.UNIT_SELECTED:
		return false

	state = BattleState.UNIT_MOVING
	movement_system.move_unit(selected_unit, cell)
	
	return true

func on_unit_move_finished():
	if selected_unit == null:
		return
	state = BattleState.UNIT_SELECTED
	refresh_selection()
	selected_action = null

func try_action_command(cell: Vector2i):
	if selected_unit == null:
		return
	if not selected_unit.can_act_this_turn():
		return
	if selected_action == null:
		return
	if cell not in action_cells:
		return

	var effects = selected_action.build_effects(selected_unit, cell, grid, unit_manager)
	if effects.is_empty():
		return

	var action_cost = max(0, selected_action.cost)
	if turn_manager != null and not turn_manager.try_spend_cp(action_cost):
		player_action_denied.emit(selected_unit, "Not enough CP")
		return

	player_action_committed.emit(selected_unit, cell, selected_action.name)
	effect_resolver.resolve_effects(effects)
	turn_manager.notify_player_unit_finished(selected_unit)
	selected_unit.has_acted_this_turn = true
	
	unit_manager.cleanup_dead_units()
	turn_manager.evaluate_battle_state()

	unselect()

func get_action_cells(unit: Unit, action: BattleAction) -> Array[Vector2i]:
	if action == null:
		return []
	return action.get_target_cells(unit, grid, unit_manager)

func apply_mission_preset(mission_id: int):
	mission_id = SaveManager.normalize_mission_id(mission_id)
	var path := "res://data/missions/mission_%d/" % mission_id + "mission_%d.tres" % mission_id

	if not ResourceLoader.exists(path):
		push_error("Mission not found: " + path)
		return

	var mission: MissionData = load(path)

	apply_mission(mission)

func apply_mission(mission: MissionData):
	if mission == null:
		push_error("No mission data")
		
	grid.setup(mission.grid_size)
		
	unit_manager.clear_all_units()
	
	environment_manager.objective_cell = mission.objective_cell
	environment_manager.objective_max_hp = mission.objective_max_hp
	
	turn_manager.cp_max = mission.cp_max
	turn_manager.threat_growth_per_turn = mission.threat_growth_per_turn
	
	for unit_spawn in mission.unit_spawns:
		unit_manager.spawn_unit(
			unit_spawn.unit_data,
			unit_spawn.team,
			unit_spawn.cell
		)
	
	environment_manager.reset_state()
	
	turn_manager.turn_index = 1
	turn_manager.start_battle()

func _on_action_selected(action: BattleAction):
	selected_action = action
	
	if selected_unit == null:
		return
	
	if not selected_unit.can_act_this_turn():
		return
	
	state = BattleState.ACTION_TARGETING
	
	action_cells = action.get_target_cells(
		selected_unit,
		grid,
		unit_manager
	)
	
	grid.remove_visual_flag_from_all_cells(Tile.Visual.ACTION_TARGET)
	
	grid.set_visual_flag_to_cells(
		action_cells,
		Tile.Visual.ACTION_TARGET
	)

func update_movement_visual():
	grid.remove_all_visual_flags_from_tiles()
	
	if selected_unit == null:
		return
	
	if selected_unit.can_move_this_turn():
		reachable_cells = movement_system.get_reachable_cells(selected_unit)
		grid.set_visual_flag_to_cells(reachable_cells, Tile.Visual.REACHABLE)
	else:
		reachable_cells.clear()

func update_action_visual():
	action_cells.clear()
	
	if selected_unit == null:
		return
	
	if selected_action == null:
		return
	
	if not selected_unit.can_act_this_turn():
		return
	
	action_cells = selected_action.get_target_cells(
		selected_unit,
		grid,
		unit_manager
	)
	
	grid.set_visual_flag_to_cells(action_cells, Tile.Visual.ACTION_TARGET)
