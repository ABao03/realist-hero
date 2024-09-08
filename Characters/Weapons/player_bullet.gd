extends Sprite2D

# changeable stats
var speed = 500 # move to set_stats

# unchangeable stats
var type : String
var bulletClass : String
var direction : Vector2

# nodes
@onready var animation = $AnimationPlayer
@onready var hitbox = $HitBox 

# origin
@onready var weapon_origin = get_tree().get_first_node_in_group("weapon_origin")

func _ready():
	animation.play("idle")
	direction = (get_global_mouse_position() - global_position).normalized()
	position = weapon_origin.position

func _process(delta):
	position += direction*speed*delta

func setup(imageFilePath : String, damage : int):
	texture = load(imageFilePath)
	hitbox.damage = damage
