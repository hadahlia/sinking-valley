extends Control
class_name PlayerUI

@onready var hp: Label = $hud/footer/hp
@onready var def: Label = $hud/footer/def
@onready var dmg: Label = $hud/footer/dmg

@onready var status_text: RichTextLabel = $hud/footer/status_text

var msg_id : int = 0

func _ready() -> void:
	status_text.text = ""

func send_event_message(input: String) -> void:
	#if msg_id >= 4:
		#status_text.text = ""
		#msg_id = 0
	status_text.append_text("\n" + input)
	#msg_id += 1
	
		#var first_n : int = status_text.text.find("\n")
		#assert(first_n != 1, "Could not find first line")

func set_health(new_hp: int, max_hp: int)->void:
	hp.text = "HP :" + str(new_hp) + " / " + str(max_hp)

func set_defense(new_defense: int)->void:
	def.text = "DEF :" + str(new_defense)

func set_dmg(new_dmg: int)->void:
	dmg.text = "DMG :" + str(new_dmg)
