extends CharacterBody2D

@export var movement_speed = 0.0
@export var hp = 0.0
@export var experience = 0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var sprite = $Sprite2D
@onready var damage_numbers_origin = $DamageNumbers

func _physics_process(_delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction*movement_speed
	move_and_slide()
	
	#if direction.x > 0.1:
		#sprite.flip_h = true
	#elif direction.x < -0.1:
		#sprite.flip_h = false

func _on_hurt_box_hurt(damage, isMagic, isCrit):
	if isCrit == true:
		damage = damage * 2
	DamageNumbers.display_number(damage, damage_numbers_origin.global_position, isMagic, isCrit)

