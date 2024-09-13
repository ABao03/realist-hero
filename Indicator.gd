extends Sprite2D

@onready var reticle = load("res://Assets/Images/reticle.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	texture = reticle

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = get_global_mouse_position()
