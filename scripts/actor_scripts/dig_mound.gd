extends Interactable
class_name DirtMound
# named it dirt but its more like general reward item?

@onready var reward_slot: CanvasLayer = $"reward slot"
@onready var slot: Panel = $"reward slot/Slot"

#@export var item_treasure <- item to reward

#func _ready() -> void:


func dig():
	#if GameFlags.has_shovel:
	var event :Control= get_tree().get_first_node_in_group("EventMessager")
	event.send_event_message(event_text)
	slot.show()
		# it would, give you the item export var and then delete itself ^-^
		#pass
