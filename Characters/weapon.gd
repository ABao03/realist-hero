extends Marker2D

@onready var players = get_tree().get_nodes_in_group("player")
var player

@onready var animation = $Sprite2D/AnimationPlayer
@onready var hitbox1 = $Sprite2D/HitBox
@onready var hitbox2 = $Sprite2D/HitBox2

# Animation speed variables (for attack speed)
var rotationSpeed = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	for thisPlayer in players:
		if thisPlayer != null:
			player = thisPlayer
	visible = false

func attack():
	visible = true
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

func set_physical(val):
	hitbox1.damage = val
	hitbox2.damage = val

func set_magic(val):
	hitbox1.magicDamage = val
	hitbox2.magicDamage = val

func set_crit(val):
	hitbox1.crit = val
	hitbox2.crit = val

func get_physical():
	return hitbox1.damage

func get_magic():
	return hitbox1.magicDamage

func get_crit():
	return hitbox1.crit
