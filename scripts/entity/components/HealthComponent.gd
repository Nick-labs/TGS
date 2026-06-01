class_name HealthComponent
extends ObjectComponent

@export var max_hp := 1

var hp := 0

func on_added(owner):
	hp = max_hp
