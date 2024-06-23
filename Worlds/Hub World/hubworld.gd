extends Node2D

@onready var player = $PlayerAdolf

# Called when the node enters the scene tree for the first time.
func _ready():
	player.disable_light()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_door_1_body_entered(body):
	#get_tree().change_scene_to_file("res://Worlds/Procedural  World/Random-world.tscn")
	SceneManager.load_new_scene("res://Worlds/Procedural  World/Random-world.tscn","wipe_to_right")

func _on_door_2_body_entered(body):
	get_tree().change_scene_to_file("res://Menu/menu.tscn")

func _on_button_pressed():
	Dialogic.start("timeline")
