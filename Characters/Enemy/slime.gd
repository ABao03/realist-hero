extends CharacterBody2D

@export var movement_speed = 100.0
@export var hp = 100
@export var experience = 1
@export var knockback = -5

@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var last_position
@onready var sprite = $Slime
@onready var hurtbox = $HurtBox
@onready var damage_numbers_origin = $DamageNumbers

@onready var snd = $Snd
@onready var animation_tree = $AnimationTree
@onready var hurtAnimationPlaying = false

var loot = preload("res://Characters/Enemy/Drops/loot_drop.tscn")

func _ready():
	sprite.visible = false

# Moving slime around 
func _physics_process(_delta):
	var direction = to_local(nav_agent.get_next_path_position()).normalized()
	
	velocity = direction * movement_speed
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

func make_path():
	nav_agent.target_position = player.global_position
	print(to_local(nav_agent.get_next_path_position()))
	if last_position == nav_agent.get_next_path_position(): 
		queue_free()
	if last_position != Vector2(0,0):
		sprite.visible = true
	
	last_position = to_local(nav_agent.get_next_path_position())

# Slime is killed by damage
func death():
	var new_gem = loot.instantiate()
	new_gem.global_position = global_position
	new_gem.experience = experience
	loot_base.call_deferred("add_child", new_gem)
	queue_free()

func _on_hurt_box_hurt(damage, magicDamage, isCrit):
	if isCrit == true:
		damage = damage * 1.5
	hp -= damage
	hp -= magicDamage
	DamageNumbers.display_number(damage, damage_numbers_origin.global_position, magicDamage, isCrit)
	
	if magicDamage == 0 && isCrit == false:
		snd.stream = load("res://Assets/SoundEffects/hit.wav")
		snd.play()
	if isCrit == true:
		snd.stream = load("res://Assets/SoundEffects/crit_hit.mp3")
		snd.play()
	
	if hp <= 0:
		death()
	else:
		animation_tree["parameters/conditions/hurt"] = true
		hurtAnimationPlaying = true


func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "hurt":
		hurtAnimationPlaying = false


func _on_timer_timeout():
	make_path()


func _on_area_2d_body_entered(body):
	#print(player.global_position)
	pass
