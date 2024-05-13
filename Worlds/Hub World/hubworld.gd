extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass




func _on_door_1_body_entered(body):
	get_tree().change_scene_to_file("res://Worlds/Procedural  World/Random-world.tscn")
	



func _on_door_2_body_entered(body):
	get_tree().change_scene_to_file("res://Menu/menu.tscn")
