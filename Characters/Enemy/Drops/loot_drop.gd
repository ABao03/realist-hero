extends Area2D
@export var experience = 1
@export var isChest = false
@export var chestRarity = 0    # 1 is common, 2 is rare
var star_sprite = preload("res://Assets/Images/Star Stage 1.png")

var chest_chance = 6
var rare_chest_chance = 2

var target = null
var speed = 40

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var sound = $snd_collected

# Called when the node enters the scene tree for the first time.
func _ready():
	# Disabled for now cuz chests are useless
	#if randi() % chest_chance == 0:
		#isChest = true
		#if randi() % rare_chest_chance == 0:
			#sprite.texture = rare_chest_sprite
			#chestRarity = 2
		#else:
			#sprite.texture = chest_sprite
			#chestRarity = 1
		#sprite.scale = Vector2(0.12, 0.12)
	#else:
		isChest = false
		sprite.texture = star_sprite
	# You can modify the sprite based on the experience value here. Maybe implement rarity? 

func _physics_process(delta): 
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 2 * delta
		
func collect():
	sound.play()
	collision.call_deferred("set", "disabled", true)
	sprite.visible = false
	
	# Catch chest (disabled for now because chests are sorta useless)
	#if isChest == true:
		#return 1
		
	return experience
	
func _on_snd_collected_finished():
	queue_free()
