extends Node2D

@onready var label: Label = $Label

func setup(amount: int):
	label.text = str(amount)

	var tween = create_tween()

	tween.parallel().tween_property(
		self,
		"position:y",
		position.y - 40,
		0.8
	)

	tween.parallel().tween_property(
		self,
		"modulate:a",
		0.0,
		0.8
	)

	await tween.finished
	queue_free()
