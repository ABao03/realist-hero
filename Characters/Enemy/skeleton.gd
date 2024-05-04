extends CharacterBody2D

@export var movement_speed = 30.0

var maxHealth = 20.0
@export var health = maxHealth

@export var experience = 3
@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var sprite = $Skeleton

var loot = preload("res://Characters/Enemy/Drops/loot_drop.tscn")

var player_chase = false
var player_presence = null

func _physics_process(_delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction*movement_speed
	move_and_slide()
	$Skeleton.play("Walking")
	update_health()
	
	if direction.x > 0.1:
		sprite.flip_h = false
	elif direction.x < -0.1:
		sprite.flip_h = true

# Slime is killed by damage
func death():
	var new_gem = loot.instantiate()
	new_gem.global_position = global_position
	new_gem.experience = experience
	loot_base.call_deferred("add_child", new_gem)
	queue_free()

func _on_hurt_box_hurt(damage):
	health -= damage
	if health <= 0:
		death()

func update_health():
	var healthbar = $HealthBar
	
	healthbar.value = (health/maxHealth)*100
	
	if healthbar.value == 100:
		healthbar.visible = false
	else:
		healthbar.visible = true
