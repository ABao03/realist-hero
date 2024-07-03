extends Node2D
@onready var spawner = $EnemySpawner
@onready var player = get_node("PlayerAdolf")
# Called when the node enters the scene tree for the first time.
func _ready():
	Dialogic.signal_event.connect(_on_dialogic_signal)
	spawner.pause_spawning()
	Dialogic.start("tutorial")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player.signal_emitted:
		Dialogic.start("tutorial_2")
		player.signal_emitted = false

func _on_dialogic_signal(argument):
	if argument == "tutorial_enemies":
		spawner.start_spawning()
	elif argument == "tutorial_ended":
		SceneManager.load_new_scene("res://Worlds/Hub World/hubworld.tscn", "wipe_to_right")
