extends Panel

@export var item : Item = null:
	set(value):
		item = value
		
		if(value) == null:
			%Icon.texture = null
			%Amount.text = ""
			return
		%Icon.texture = value.picture
		
@export var amount : int = 0:
	set(value):
		amount = value
		%Amount.text = str(value)
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
	if "item" in data:
		return is_instance_of(data.item, Item)
	return false

func _drop_data(at_position, data):
	var temp = item
	item = data.item
	data.item = temp
	
	temp = amount
	amount = data.amount
	data.amount = temp

func _get_drag_data(at_position):
	if(item):
		var preview_texture = TextureRect.new()
		preview_texture.texture = item.picture
		preview_texture.size = Vector2(16,16)
		preview_texture.position = -Vector2(8,8)
		var preview = Control.new()
		preview.add_child(preview_texture)
		set_drag_preview(preview)
	return self
