extends Control
class_name ActionBar

signal action_selected(action: BattleAction)

@export var button_scene: PackedScene

@onready var container: HBoxContainer = $Panel/MarginContainer/CenterContainer/HBoxContainer

var current_unit: Unit

func show_unit_actions(unit: Unit):
	current_unit = unit

	clear_buttons()

	if unit == null:
		visible = false
		return

	visible = true

	for action in unit.actions:
		if action == null:
			continue

		var button: Button = button_scene.instantiate()

		button.text = action.name

		button.pressed.connect(func(a = action):
			action_selected.emit(a)
		)

		container.add_child(button)

func clear_buttons():
	for child in container.get_children():
		child.queue_free()
