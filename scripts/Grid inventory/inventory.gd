extends Control

#@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var overworld_slot: Panel = $CanvasLayer/Overworld_Slot
@onready var grid_container: GridContainer = $CanvasLayer/GridContainer


func _input(event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("inventory"):
		grid_container.visible = !grid_container.visible
		overworld_slot.visible = !overworld_slot.visible
