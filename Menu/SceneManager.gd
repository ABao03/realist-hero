# Bacon and Games on YouTube: https://www.youtube.com/watch?v=2uYaoQj_6o0
extends Node

signal content_finished_loading(content)

var loading_screen:LoadingScreen
var _loading_screen_scene:PackedScene = preload("res://Menu/loading_screen.tscn")
var _transition:String
var _content_path:String
var _load_progress_timer:Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	content_finished_loading.connect(on_content_finished_loading)

func load_new_scene(content_path:String, transition_type:String="fade_to_black"):
	_transition = transition_type
	# add loading screen
	loading_screen = _loading_screen_scene.instantiate() as LoadingScreen
	get_tree().root.add_child(loading_screen)
	loading_screen.start_transition(transition_type)
	_load_content(content_path)
	
func _load_content(content_path:String) -> void:
	if loading_screen != null:
		await loading_screen.transition_in_complete
		
	_content_path = content_path
	var loader = ResourceLoader.load_threaded_request(content_path)
	
	_load_progress_timer = Timer.new()
	_load_progress_timer.wait_time = 0.1
	_load_progress_timer.timeout.connect(monitor_load_status)
	get_tree().root.add_child(_load_progress_timer)
	_load_progress_timer.start()
	
# checks in on loading status 
func monitor_load_status() -> void:
	var load_progress = []
	var load_status = ResourceLoader.load_threaded_get_status(_content_path, load_progress)

	match load_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if loading_screen != null:
				loading_screen.update_bar(load_progress[0] * 100) # 0.1
		ResourceLoader.THREAD_LOAD_LOADED:
			_load_progress_timer.stop()
			_load_progress_timer.queue_free()
			content_finished_loading.emit(ResourceLoader.load_threaded_get(_content_path).instantiate())
	
func on_content_finished_loading(content) -> void:
	var outgoing_scene = get_tree().current_scene
	var duplicateInventory = []
	
	# If we're moving between Levels, pass LevelDataHandoff here
	#incoming_data = get_tree().current_scene.data as LevelDataHandoff
	#
	#if content is Level:
		#content.data = incoming_data
	if outgoing_scene.name == "Random-world" && content.name == "Death":
		var outgoing_inventory = outgoing_scene.get_tree().get_first_node_in_group("inventory")
		for item in outgoing_inventory.currentInventory + outgoing_inventory.componentInventory:
			duplicateInventory.append(DataHandler.deep_clone(item))
	
	# Remove the old scene
	outgoing_scene.queue_free()
	
	# Add and set the new scene to current
	get_tree().root.call_deferred("add_child",content)
	get_tree().set_deferred("current_scene",content)
	#get_tree().change_scene_to_file(content)
	
	# probably not necssary since we split our content_finished_loading but it won't hurt to have an extra check
	if loading_screen != null:
		loading_screen.finish_transition()
		# wait for LoadingScreen's transition to finish playing
		await loading_screen.anim_player.animation_finished
		loading_screen = null
		
		if content.name == "Death":
			content.deathInventory = duplicateInventory
			content.tallyInventory()
