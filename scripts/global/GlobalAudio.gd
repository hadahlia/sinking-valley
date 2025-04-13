extends Node

# SFX
const SFX_INTERACT : AudioStream = preload("res://sound/sfx/BNA_UI24.wav")


# MUSIC


# you can call this global script, and pass in the global sfx consts ^^
func play_sound(stream: AudioStream):
	var inst = AudioStreamPlayer.new()
	inst.stream = stream
	inst.volume_db -= 3
	inst.finished.connect(remove_audio.bind(inst))
	add_child(inst)
	inst.play()

func remove_audio(inst: AudioStreamPlayer):
	inst.queue_free()
