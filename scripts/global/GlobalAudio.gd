extends Node

# SFX
const SFX_INTERACT_DENY : AudioStream = preload("res://sound/sfx/interact_deny.wav")
const INVENTORY_OPEN : AudioStream = preload("res://sound/sfx/inv_open_ui28.wav")
const INVENTORY_CLOSE : AudioStream = preload("res://sound/sfx/inv_close_UI4.wav")

const SEA_LOOP : AudioStream = preload("res://sound/sfx/Ambiance_Sea_Loop_Stereo.wav")

# MUSIC
const DUNGEON_THEME : AudioStream = preload("res://sound/music/dungeon.ogg")

# you can call this global script, and pass in the global sfx consts ^^
func play_sound(stream: AudioStream):
	var inst = AudioStreamPlayer.new()
	inst.stream = stream
	inst.volume_db -= 5
	inst.finished.connect(remove_audio.bind(inst))
	add_child(inst)
	inst.play()

func play_music(stream:AudioStream):
	var inst = AudioStreamPlayer.new()
	inst.stream = stream
	inst.volume_db -= 8
	#inst.volume_db -= 3
	#inst.finished.connect(remove_audio.bind(inst))
	add_child(inst)
	inst.play()

func remove_audio(inst: AudioStreamPlayer):
	inst.queue_free()
