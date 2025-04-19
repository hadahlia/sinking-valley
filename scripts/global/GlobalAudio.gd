extends Node

# SFX
const SFX_INTERACT_OK : AudioStream = preload("res://sound/sfx/ineract_accept_UI60.wav")
const SFX_INTERACT_DENY : AudioStream = preload("res://sound/sfx/interact_deny.wav")
#const INVENTORY_OPEN : AudioStream = preload("res://sound/sfx/inv_open_ui28.wav")
#const INVENTORY_CLOSE : AudioStream = preload("res://sound/sfx/inv_close_UI4.wav")
const INVENTORY_OPEN : AudioStream = preload("res://sound/sfx/inventory_open2.wav")
const INVENTORY_CLOSE : AudioStream = preload("res://sound/sfx/inventory_close2.wav")

const ATK_CONNECT : AudioStream = preload("res://sound/sfx/action/attack_connect.wav")
const SFX_SWING : AudioStream = preload("res://sound/sfx/action/swing.wav")
const SFX_HEAL : AudioStream = preload("res://sound/sfx/action/HEALING_UI40.wav")
const SFX_HURT : AudioStream = preload("res://sound/sfx/action/takedamage_UI12.wav")


const SEA_LOOP : AudioStream = preload("res://sound/sfx/Ambiance_Sea_Loop_Stereo.wav")

# MUSIC
const DUNGEON_THEME : AudioStream = preload("res://sound/music/dungeon.ogg")

# you can call this global script, and pass in the global sfx consts ^^
func play_sound(stream: AudioStream):
	var inst = AudioStreamPlayer.new()
	inst.stream = stream
	inst.volume_db -= 8
	inst.finished.connect(remove_audio.bind(inst))
	add_child(inst)
	inst.play()

func play_music(stream:AudioStream):
	var inst = AudioStreamPlayer.new()
	inst.add_to_group("musics")
	inst.stream = stream
	inst.volume_db -= 10
	#inst.volume_db -= 3
	#inst.finished.connect(remove_audio.bind(inst))
	add_child(inst)
	inst.play()

func stop_music()->void:
	var c = get_tree().get_nodes_in_group("musics")
	
	for i in c:
		i.queue_free()

func remove_audio(inst: AudioStreamPlayer):
	inst.queue_free()
