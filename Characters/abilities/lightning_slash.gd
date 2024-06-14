extends Sprite2D
@onready var animation = $AnimationPlayer
@onready var hitbox = $HitBox

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false

func play_animation(pos):
	visible = true
	global_position = pos
	animation.play("attack")

func _on_animation_player_animation_finished(anim_name):
	visible = false
