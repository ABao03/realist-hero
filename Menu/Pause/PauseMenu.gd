extends CanvasLayer

var game_pause
var pause_visibility
# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	game_pause = false
	pause_visibility = false
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


 
