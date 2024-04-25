extends Control
func _on_start_game_pressed():
	get_tree().change_scene_to_file("res://gamemanager.tscn")


func _on_settings_pressed():
	get_tree().change_scene_to_file("res://Menu/Settings/Settings.tscn")


func _on_quit_pressed():
	get_tree().quit()
	

# إن شاء الله this becomes successful



