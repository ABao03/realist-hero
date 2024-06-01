extends CharacterBody2D

@export var movement_speed = 30.0
@export var hp = 25.0
@export var experience = 1
@export var knockback = -10.5

@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var sprite = $Sprite2D
@onready var hurtbox = $HurtBox
@onready var damage_numbers_origin = $DamageNumbers

@onready var animation_tree = $AnimationTree
@onready var hurtAnimationPlaying = false

var loot = preload("res://Characters/Enemy/Drops/loot_drop.tscn")

# Moving slime around 
func _physics_process(_delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction*movement_speed
	if hurtAnimationPlaying == true:
		velocity *= knockback
	move_and_slide()
	
	if animation_tree["parameters/conditions/hurt"] == true && hurtAnimationPlaying == false:
		animation_tree["parameters/conditions/move"] = true
		animation_tree["parameters/conditions/hurt"] = false
	
	if direction.x > 0.1:
		sprite.flip_h = true
	elif direction.x < -0.1:
		sprite.flip_h = false

# Slime is killed by damage
func death():
	var new_gem = loot.instantiate()
	new_gem.global_position = global_position
	new_gem.experience = experience
	loot_base.call_deferred("add_child", new_gem)
	queue_free()

func _on_hurt_box_hurt(damage, magicDamage, isCrit):
	if isCrit == true:
		damage = damage * 2
	hp -= damage
	DamageNumbers.display_number(damage, damage_numbers_origin.global_position, magicDamage, isCrit)
	if hp <= 0:
		death()
	else:
		animation_tree["parameters/conditions/hurt"] = true
		hurtAnimationPlaying = true


func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "hurt":
		hurtAnimationPlaying = false
