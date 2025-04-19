extends Node

# Scenes
const MAIN_SCENE : String = "res://scenes/main_scene.tscn"
const ENDING_SCENE : String = "res://scenes/UI/ending_screen.tscn"
const GAME_OVER : String = "res://scenes/UI/death_screen.tscn"
const MAIN_MENU : String = "res://scenes/UI/MainMenu.tscn"

func ChangeScene(scene):
	assert(scene != null)
	get_tree().change_scene_to_file(scene)
	
func quitGame():
	get_tree().quit()
