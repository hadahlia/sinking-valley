extends Control

@onready var grid_container: GridContainer = $CanvasLayer/GridContainer
@onready var overworld_slot: Panel = $CanvasLayer/overworld_slot


func _input(event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("inventory"):
		grid_container.visible = !grid_container.visible
		overworld_slot.visible = !overworld_slot.visible
		
		if grid_container.visible:
			GlobalAudio.play_sound(GlobalAudio.INVENTORY_OPEN)
		else:
			GlobalAudio.play_sound(GlobalAudio.INVENTORY_CLOSE)
