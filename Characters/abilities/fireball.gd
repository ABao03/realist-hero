extends Sprite2D
@onready var animation = $AnimationPlayer
@onready var hitbox = $Arrow/HitBox

# Called when the node enters the scene tree for the first time.
func _ready():
	print(hitbox)
	visible = false

func play_animation(pos):
	visible = true
	$Arrow.global_position = pos
	$Arrow.active = true
	$Arrow.look_at(get_global_mouse_position())
	#animation.play("lightning")

func fireball_left_screen():
	visible = false
	$Arrow.active = false
