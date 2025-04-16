extends Node

@export_global_file var switchTo : String

func _on_play_button_pressed():
	SceneManager.ChangeScene(switchTo)

func _on_quit_button_pressed():
	SceneManager.quitGame()
