extends Label



#func _ready() -> void:
	#text = str(GameFlags.turn_id)

func _process(delta: float) -> void:
	text = "TURN " + str(GameFlags.turn_id)
