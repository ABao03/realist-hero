extends CanvasLayer

var game_pause

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	game_pause = false
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _input(event: InputEvent): # Show/hide pause menu
	if event.is_action_pressed("esc"):
		if get_tree().paused:
			get_tree().paused = false
			hide()
		else:
			get_tree().paused = true
			show()

func _on_resume_pressed():
	get_tree().paused = false
	hide()

func _on_exit_to_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Menu/menu.tscn")	

func _on_exit_to_desktop_pressed():
	get_tree().quit()




#func _on_load_pressed(): WIP too buggy
	#var loaded_scene = load("res://save/save.tscn")
	#if loaded_scene:
		#print("Loaded resource type: ", loaded_scene.get_class())
		#if loaded_scene is PackedScene:
			#var instance = loaded_scene.instantiate()
			#get_tree().root.add_child(instance)
			#get_tree().current_scene = instance
		#else:
			#print("Loaded resource is not a PackedScene!")
	#else:
		#print("Failed to load the scene. Make sure the file exists and the path is correct.")
#
#
#
#func _on_save_pressed():
	#var scene = get_tree().player_adolf
	#var packed_scene = PackedScene.new()
	#packed_scene.pack(scene)
	#var save_path = "res://saved_scene.tscn"
	#var result = ResourceSaver.save(packed_scene, save_path)


