extends Panel

@export var item : Item = null:
	set(value):
		item = value
		
		if(value) == null:
			%Icon.texture = null
			%Amount.text = ""
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
	return false

func _drop_data(at_position, data):
	var temp = item
	item = data.item
	data.item = temp
	
	temp = amount
	amount = data.amount
	data.amount = temp
	
	GlobalAudio.play_sound(GlobalAudio.INVENTORY_CLOSE)

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

func _get_item_healing()->int:
	if(item != null):
		if(item.TYPE == "Item"):
			var ret_hp : int = item.heal_amount
			if ret_hp > 0:
				item = null
			return ret_hp
	return 0

func _get_item_attack()->int:
	if(item != null):
		if(item.TYPE == "Equipment"):
			return item.attackValue
	return 0

func _get_item_defense()->int:
	if(item != null):
		if(item.TYPE == "Equipment"):
			return item.defValue
	return 0
