extends Sprite2D

var speed : int = 100
var direction : Vector2 = Vector2.RIGHT
var duration : int = 1000

var type : int = 1 # 0 is black yin, 1 is white yang
var spriteFilePath = "res://Assets/fireBullet"

@onready var hitbox = $HitBox/CollisionShape2D
@onready var animation = $AnimationPlayer

func _ready():
	animation.play("idle")

func _physics_process(delta):
	position += direction * speed * delta
	
	duration -= delta
	if duration <= 0:
		queue_free()
