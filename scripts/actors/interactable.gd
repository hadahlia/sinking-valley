extends Node3D
class_name Interactable

@export var event_text : String = "default message"
@export var is_door: bool = true

func _trigger() -> void:
	if is_door: return
