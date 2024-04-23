extends Area2D
@export var experience = 1
var star_sprite = preload("res://Assets/Images/Star Stage 1.png")

var target = null
var speed = 0

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var sound = $snd_collected

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	# You can modify the sprite based on the experience value here. Maybe implement rarity? 

func _physics_process(delta): 
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 2 * delta	
		
func collect():
	sound.play()
	collision.call_deferred("set", "disabled", true)
	sprite.visible = false
	return experience
	
func _on_snd_collected_finished():
	queue_free()
