extends Area2D

var level = 1
var speed = 100
var damage = 5
var knock_amount = 100
var attack_size = 1.0

var target = Vector2.ZERO
var angle = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")

# Orients projectile towards target. Changes stats based on level (I think). 
func _ready():
	angle = global_position.direction_to(target)
	rotation = angle.angle() # + deg_to_rad(135)
	match level:
		1:
			speed = 100
			damage = 5
			knock_amount = 100
			attack_size = 1.0


# Projectile movement (shoots outwards)
func _physics_process(delta):
	position += angle * speed * delta
	
# Projectile hits enemy
func enemy_hit(charge = 1):
	pass
	
# on_timer_timeout for if the projectile misses 
	
	
	
	
	
	
	
