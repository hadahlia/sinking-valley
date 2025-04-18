extends Interactable
class_name TakeShovel

@onready var reward_slot: CanvasLayer = $"reward slot"
@onready var slot: Panel = $"reward slot/Slot"

#@export var item_treasure <- item to reward

func _ready() -> void:
	self.tree_exited.connect(on_destroyed)

func dig():
	#if GameFlags.has_shovel:
	var event :Control= get_tree().get_first_node_in_group("EventMessager")
	event.send_event_message("Do you take the shovel? ")
	slot.show()
		# it would, give you the item export var and then delete itself ^-^
		#pass

func on_destroyed() -> void:
	GameFlags.has_shovel = true
