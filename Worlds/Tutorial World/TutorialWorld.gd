extends Node2D
@onready var spawner = $EnemySpawner

# Called when the node enters the scene tree for the first time.
func _ready():
	spawner.pause_spawning()
	Dialogic.start("timeline")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
