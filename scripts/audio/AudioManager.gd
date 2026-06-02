extends Node

func play_sfx(sound: AudioStream):
	if sound == null:
		return
	
	var player := AudioStreamPlayer.new()
	
	add_child(player)
	
	player.stream = sound
	
	player.finished.connect(
		player.queue_free
	)
	
	player.play()
