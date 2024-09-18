extends Sprite2D

# be careful with projectile collision layer

# changeable stats
var thisItem
var bulletClass : String
var bulletType : String
var bulletCount : int
var speed : int
var piercing = 1 # probably also move to set_stats
var spinning : bool = false

# projectile stats
var direction : Vector2
var duration : int = 500
var orbitRadius : int # only for orbiting weapons
var angle = 0.0 # only for orbiting weapons

# nodes
@onready var animation = $AnimationPlayer
@onready var spinningHitBox = $CircleHitBox
@onready var straightHitBox = $RectHitBox
var activeHitBox
# connect player node so that you can check if they're currently in yin or yang mode

# origin
@onready var weapon_origin = get_tree().get_first_node_in_group("weapon_origin")

# send signals to origin
signal bulwark_deleted()
signal gauntlet_deleted()

func _ready():
	position = weapon_origin.position
	connect("bulwark_deleted",Callable(weapon_origin,"bulwark_deleted"))
	connect("gauntlet_deleted",Callable(weapon_origin,"gauntlet_deleted"))

func _process(delta):
	# If bullet class is targeted or spread, it flies in a straight line, runs out of duration, and is deleted
	if bulletClass == "Target" || bulletClass == "Spread":
		# linear motion code
		position += direction * speed * delta
		
		# duration code (despawns the bullet after a bit)
		# perhaps transition into an invisible barrier that wraps around the world and despawns everything that hits it?
		duration -= delta
		if duration <= 0:
			queue_free()
	
	# If bullet class is orbit, it flies around the player and has infinite duration
	elif bulletClass == "Orbit":
		if bulletType == "PassiveOrbit":
			angle += speed * delta
		elif bulletType == "GuidedOrbit":
			angle = (get_global_mouse_position() - position).normalized().angle()
			rotation = angle + deg_to_rad(135)
		position.x = weapon_origin.position.x + orbitRadius * cos(angle)
		position.y = weapon_origin.position.y + orbitRadius * sin(angle)

func setup(itemID : String, isSpinning : bool):
	# load item data from JSON
	thisItem = DataHandler.item_data[itemID]
	
	# Load bullet texture
	var textureName = thisItem["Name"].replace("'", "")
	textureName = textureName.replace(" ", "_")
	textureName = textureName.to_lower()
	texture = load("res://Assets/Images/Bullets/" + textureName + "_weapon.png")
	
	# Load bullet stats
	bulletClass = thisItem["Class"]
	bulletCount = thisItem["BulletCount"]
	bulletType = thisItem["BulletType"]
	speed = thisItem["Speed"] * 50
	
	# Direction of the bullet: how it's fired, how it moves
	if bulletClass == "Target":
		direction = (get_global_mouse_position() - global_position).normalized()
	
	# Set spinning status 
	spinning = isSpinning
	
	# Appearance of the bullet: what is looks like while moving, changing the hitbox to match the appearance
	if spinning == false:
		animation.play("idle")
		rotation = direction.angle() + deg_to_rad(45)
		activeHitBox = straightHitBox
	else:
		animation.play("spinning")
		activeHitBox = spinningHitBox
	
	# Set the hitbox based on weapon damage and which type of hitbox is active
	activeHitBox.collision.disabled = false
	activeHitBox.damage = thisItem["Damage"]

func add_spread(currBulletIndex : int):
	var spreadAngle = deg_to_rad(360/bulletCount * currBulletIndex)
	direction = Vector2(cos(spreadAngle), sin(spreadAngle))
	rotation = spreadAngle + deg_to_rad(45)

func add_random_spread():
	var randomAngle = randf() * TAU
	direction = Vector2(cos(randomAngle), sin(randomAngle))
	rotation = randomAngle + deg_to_rad(45)

# Bullet death animation
func explode():
	var deathParticle : PackedScene = load("res://Characters/Weapons/deathParticle.tscn")
	var _particle = deathParticle.instantiate()
	_particle.position = global_position
	_particle.rotation = global_rotation
	_particle.emitting = true
	get_tree().current_scene.add_child(_particle)
	
	if thisItem["Name"] == "Bulwark":
		emit_signal("bulwark_deleted")
	
	if thisItem["Name"] == "Gauntlets":
		emit_signal("gauntlets_deleted")
	queue_free()

func _on_circle_hit_box_area_entered(area):
	piercing -= 1
	if piercing <= 0:
		explode()

func _on_rect_hit_box_area_entered(area):
	piercing -= 1
	if piercing <= 0:
		explode()

func check_bulwark_count(currentCount : int):
	if currentCount > bulletCount:
		emit_signal("bulwark_deleted")
		queue_free()
