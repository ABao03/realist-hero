extends Control
func _on_start_game_pressed():
	#get_tree().change_scene_to_file("res://Worlds/Procedural  World/Random-world.tscn")
	#get_tree().change_scene_to_file("res://Worlds/Hub World/hubworld.tscn")
	SceneManager.load_new_scene("res://Worlds/Procedural  World/Random-world.tscn","wipe_to_right")


func _on_settings_pressed():
	get_tree().change_scene_to_file("res://Menu/Settings/New_setting.tscn")


func _on_quit_pressed():
	get_tree().quit()
	

# إن شاء الله this becomes successful


func _on_button_pressed():
	OS.shell_open("https://discord.gg/PVaUdtWrxP")
