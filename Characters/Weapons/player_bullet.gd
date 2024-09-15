extends Sprite2D

# be careful with projectile collision layer

# changeable stats
var speed = 500 # move to set_stats
var piercing = 1 # probably also move to set_stats
var spinning : bool = false

# unchangeable stats
var type : String
var bulletType : String
var bulletClass : String
var direction : Vector2
var duration : int = 500

# nodes
@onready var animation = $AnimationPlayer
@onready var hitbox = $SpinningHitBox 
# connect player node so that you can check if they're currently in yin or yang mode

# origin
@onready var weapon_origin = get_tree().get_first_node_in_group("weapon_origin")

func _ready():
	position = weapon_origin.position

func _process(delta):
	position += direction * speed * delta
	
	duration -= delta
	if duration <= 0:
		queue_free()

func setup(imageFilePath : String, damage : int, isSpinning : bool):
	global_position = position
	direction = (get_global_mouse_position() - global_position).normalized()
	spinning = isSpinning
	
	if spinning == false:
		animation.play("idle")
		rotation = direction.angle() + deg_to_rad(45)
	else:
		animation.play("spinning")
	
	texture = load(imageFilePath)
	hitbox.damage = damage

func explode():
	var deathParticle : PackedScene = load("res://Characters/Weapons/deathParticle.tscn")
	var _particle = deathParticle.instantiate()
	_particle.position = global_position
	_particle.rotation = global_rotation
	_particle.emitting = true
	get_tree().current_scene.add_child(_particle)
	
	queue_free()

func _on_hit_box_area_entered(area):
	piercing -= 1
	if piercing <= 0:
		explode()
