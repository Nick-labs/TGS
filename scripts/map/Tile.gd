extends Node2D
class_name Tile

enum State {
	NORMAL,
	HOVER,
	SELECTED,
	REACHABLE
}

var coord: Vector2i
var state: State = State.NORMAL

func set_state(new_state: State):
	state = new_state
	_update_visual()

func _update_visual():
	match state:
		State.NORMAL:
			modulate = Color.WHITE

		State.HOVER:
			modulate = Color.YELLOW

		State.SELECTED:
			modulate = Color.GREEN

		State.REACHABLE:
			modulate = Color(0.3, 0.8, 1.0)
