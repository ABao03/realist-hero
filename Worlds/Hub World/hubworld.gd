extends Node2D

@onready var player = $PlayerAdolf

func _on_door_1_body_entered(body):
	#get_tree().change_scene_to_file("res://Worlds/Procedural  World/Random-world.tscn")
	SceneManager.load_new_scene("res://Worlds/Procedural  World/Random-world.tscn","wipe_to_right")

func _on_door_2_body_entered(body):
	get_tree().change_scene_to_file("res://Menu/menu.tscn")

func _on_button_pressed():
	SceneManager.load_new_scene("res://Worlds/Tutorial World/tutorial_world.tscn","wipe_to_right")
