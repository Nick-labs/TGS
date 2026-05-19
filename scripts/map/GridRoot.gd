extends Node2D
class_name GridRoot

@export var camera: Camera2D
@export var grid: Grid

@export var padding_percent := 0.1

func _ready() -> void:
	call_deferred("fit_grid_to_screen")

func fit_grid_to_screen() -> void:
	if grid == null:
		return

	var viewport_size: Vector2 = get_viewport_rect().size
	var available_size: Vector2 = viewport_size * (1.0 - padding_percent * 2.0)
	var bounds: Rect2 = grid.get_bounds()
	var grid_size: Vector2 = bounds.size
	var scale_x: float = available_size.x / grid_size.x
	var scale_y: float = available_size.y / grid_size.y
	var scale: float = min(scale_x, scale_y)
	camera.zoom = Vector2(scale, scale)
	center_on_bounds(bounds)

func center_on_bounds(bounds: Rect2) -> void:
	var center_local: Vector2 = bounds.position + bounds.size * 0.5
	camera.global_position = grid.to_global(center_local)

func center_grid() -> void:
	var center := Vector2((grid.width - 1) / 2.0, (grid.height - 1) / 2.0)
	var center_screen := IsoHelper.grid_to_screen(Vector2i(center), grid.iso_config)
	camera.global_position = grid.to_global(center_screen)

func apply_mission_preset(mission_id: int):
	mission_id = SaveManager.normalize_mission_id(mission_id)

	var path := "res://data/missions/mission_%d/mission.tres" % mission_id

	if not ResourceLoader.exists(path):
		push_error("Mission not found: " + path)
		return

	var mission: MissionData = load(path)

	apply_mission(mission)

func apply_mission(mission: MissionData):
	var unit_manager: UnitManager = get_node("UnitManager")
	var turn_manager: TurnManager = get_node("TurnManager")
	var environment_manager: EnvironmentManager = get_node("EnvironmentManager")
	
	unit_manager.clear_all_units()
	
	if mission == null:
		push_error("No mission data")
	
	environment_manager.objective_cell = mission.objective_cell
	environment_manager.objective_max_hp = 6
	
	turn_manager.cp_max = 3
	turn_manager.threat_growth_per_turn = 1
	
	for spawn in mission.unit_spawns:
		print(spawn.unit_data.display_name)
		unit_manager.spawn_unit(
			spawn.unit_data,
			spawn.team,
			spawn.cell
		)
	
	environment_manager.reset_state()
	
	turn_manager.turn_index = 1
	turn_manager.start_battle()
	
	grid.refresh_ownership_visuals()
