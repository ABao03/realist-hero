extends Sprite2D

var speed : int = 100
var direction : Vector2 = Vector2.RIGHT
var duration : int = 1000

var type : int = 1 # 0 is black yin, 1 is white yang
var spriteFilePath = "res://Assets/fireBullet"

@onready var yinHitBox = $YinHitBox/CollisionShape2D
@onready var yangHitBox = $YangHitBox/CollisionShape2D
@onready var animation = $AnimationPlayer

func _ready():
	if type == 0:
		texture = load(spriteFilePath + "Yin-Sheet.png")
		yinHitBox.disabled = false
		yangHitBox.disabled = true
	else:
		texture = load(spriteFilePath + "Yang-Sheet.png")
		yinHitBox.disabled = true
		yangHitBox.disabled = false
	
	animation.play("idle")

func _physics_process(delta):
	position += direction * speed * delta
	
	duration -= delta
	if duration <= 0:
		queue_free()
