extends Panel

@export var item : Equipment = null:
	set(value):
		item = value
		if(value) == null:
			%"Equipment icon".texture = null
			return
		%"Equipment icon".texture = value.picture

var amount : int = 1

func _can_drop_data(at_position, data):
	if(data.item != null):
		if "item" in data:
			if(data.item.TYPE == "Equipment"):
				return is_instance_of(data.item, Equipment)
	return false

func _drop_data(at_position, data):
	var temp = item
	item = data.item
	data.item = temp
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
