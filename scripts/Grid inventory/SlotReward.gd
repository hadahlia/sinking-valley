extends Panel

@onready var dig_mound: Node3D = $"../.."


@export var item : Item = null:
	set(value):
		item = value
		#print("set")
		if(value) == null:
			%Icon.texture = null
			%Amount.text = ""
			if dig_mound:
				GameFlags.can_move = true
				dig_mound.queue_free()
			#get_tree().get_parent().get_parent().queue_free()
			return
		%Icon.texture = value.picture
		
@export var amount : int = 1:
	set(value):
		amount = value
		#%Amount.text = str(value)
		if(amount <= 0):
			item = null

func SetAmount(value : int):
	amount = value

func AddAmount(value : int):
	amount += value
	
func SubtractAmount(value : int):
	if(amount > value):
		print("Not enough of this item")
	else:
		amount -= value
		
func _can_drop_data(at_position, data):
	if(data.item != null):
		if "item" in data:
			if(data.item.TYPE == "Equipment"):
				return is_instance_of(data.item, Equipment)
			else:
				return is_instance_of(data.item, Item)
	#print("cant drop data!")
	return false

func _drop_data(at_position, data):
	var temp = item
	item = data.item
	data.item = temp
	
	temp = amount
	amount = data.amount
	data.amount = temp
	#print("data dropped")

func _get_drag_data(at_position):
	if(item):
		var preview_texture = TextureRect.new()
		preview_texture.texture = item.picture
		preview_texture.size = Vector2(16,16)
		preview_texture.position = -Vector2(8,8)
		var preview = Control.new()
		preview.add_child(preview_texture)
		set_drag_preview(preview)
		#print("get drag data")
	return self
