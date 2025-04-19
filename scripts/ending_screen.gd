extends Control

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		#get_tree().reload_current_scene()
		SceneManager.ChangeScene(SceneManager.MAIN_MENU)
