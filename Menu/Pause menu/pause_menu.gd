extends Control
@export var game_manager : gamemanager
# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	game_manager.connect("toggle_game_paused",on_game_manager_toggle_game_paused)
func _process(delta):
	pass
func on_game_manager_toggle_game_paused(is_paused : bool):
	if(is_paused):
		show()
	else:
		hide()

func _on_resume_pressed():
	game_manager.game_paused = false

func _on_exit_to_menu_pressed():
	game_manager.game_paused = false
	get_tree().change_scene_to_file("res://Menu/menu.tscn")	


func _on_exit_to_desktop_pressed():
	get_tree().quit()
