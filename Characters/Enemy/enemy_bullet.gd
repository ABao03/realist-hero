extends Sprite2D

var speed : int = 100
var direction : Vector2 = Vector2.RIGHT
var duration : int = 1500

var type : int = 1 # 0 is black yin, 1 is white yang

@onready var yinHitBox = $YinHitBox/CollisionShape2D
@onready var yangHitBox = $YangHitBox/CollisionShape2D

func _ready():
	if type == 0:
		modulate = Color(0, 0, 0)
		yinHitBox.disabled = false
		yangHitBox.disabled = true
	else:
		yinHitBox.disabled = true
		yangHitBox.disabled = false

func _physics_process(delta):
	position += direction * speed * delta
	
	duration -= delta
	if duration <= 0:
		queue_free()
