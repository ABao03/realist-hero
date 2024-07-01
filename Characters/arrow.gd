extends Area2D

var speed = 300
var active = false

signal left_screen

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)
	connect("left_screen", Callable(get_parent(),"fireball_left_screen"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active:
		position += (Vector2.RIGHT*speed).rotated(rotation)*delta

	
func _on_visible_on_screen_enabler_2d_screen_exited():
	#queue_free()
	emit_signal("left_screen")
	
