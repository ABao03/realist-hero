extends CharacterBody2D

@export var movement_speed = 50.0
@export var hp = 5.0
@export var experience = 1

@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var sprite = $Sprite2D

var exp_gem = preload("res://Characters/Enemy/Drops/xp_drop.tscn")

# Moving slime around 
func _physics_process(_delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction*movement_speed
	move_and_slide()
	
	if direction.x > 0.1:
		sprite.flip_h = true
	elif direction.x < -0.1:
		sprite.flip_h = false

# Slime is killed by damage
func death():
	var new_gem = exp_gem.instantiate()
	new_gem.global_position = global_position
	new_gem.experience = experience
	loot_base.call_deferred("add_child", new_gem)
	queue_free()

func _on_hurt_box_hurt(damage):
	hp -= damage
	if hp <= 0:
		death()
