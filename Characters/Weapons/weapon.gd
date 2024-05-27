extends Marker2D
@onready var player = get_tree().get_first_node_in_group("player")

@onready var animation = $Area2D/AnimationPlayer
@onready var physicalHitbox = $Area2D/HitBox
@onready var magicHitbox = $Area2D/HitBox2

# Animation speed variables (for attack speed)
var rotationSpeed = 0.05

# Called when the node enters the scene tree for the first time.
func _ready():
	# Slow down starting attack speed
	animation.speed_scale = 0.5

func handleInput():
	if Input.is_action_just_pressed("mouse_leftclick"):
		animation.play("attack")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Calculate the direction vector pointing from the follower to the player
	var direction = (player.global_position - global_position)
	
	# Hold sword in place while attack animation plays 
	if animation.is_playing() == false:
		var mouseDirection = get_global_mouse_position() - global_position
		#look_at(get_global_mouse_position())
		var mouseAngle = mouseDirection.angle()
		var r = global_rotation
		global_rotation = lerp_angle(r, mouseAngle, rotationSpeed)
		
	# Move the follower towards the player
	global_position += direction * player.speed * delta
	
	handleInput()

func changeWeaponDamage(value):
	if value > 2:
		physicalHitbox.damage += value
	else:
		physicalHitbox.damage *= value

func changeMagicDamage(value):
	if value > 2 || value == 1:
		magicHitbox.damage += value
	else:
		magicHitbox.damage *= value

func changeWeaponCrit(value):
	physicalHitbox.crit += value - 1

func changeWeaponSpeed(value):
	var currentSpeed = animation.speed_scale
	animation.speed_scale = currentSpeed * value
	rotationSpeed = rotationSpeed * value
