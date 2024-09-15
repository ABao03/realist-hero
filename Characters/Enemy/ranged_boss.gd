extends CharacterBody2D

@export var movement_speed = 30.0
@export var hp = 5000
@export var experience = 10
@export var knockback = -5
var enemy_type = 1

@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var last_position = Vector2(0,0)
@onready var sprite = $Dragon
@onready var hurtbox = $HurtBox
@onready var damage_numbers_origin = $DamageNumbers

@onready var snd = $Snd
@onready var animation_tree = $AnimationTree
@onready var hurtAnimationPlaying = false

@onready var just_spawned = true
var loot = preload("res://Characters/Enemy/Drops/loot_drop.tscn")
@onready var in_range : bool = false
var bow_cooldown = true
var arrow_shot = false
var arrow = preload("res://Characters/Enemy/fireball.tscn")

@onready var spawner = get_tree().get_first_node_in_group("spawner")

signal died()

func _ready():
	sprite.visible = false
	#if just_spawned == true:
	$SpawnTimer.start()
	connect("died",Callable(spawner,"start_spawn_minions"))

# Moving slime around 
func _physics_process(_delta):
	var direction = to_local(nav_agent.get_next_path_position()).normalized()
	
	velocity = direction * movement_speed
		
	if in_range == true and just_spawned == false:
		velocity = Vector2(0.01,0.01)
		
		if bow_cooldown == true:
			bow_cooldown = false
			
			var player_pos = player.global_position
			$Marker2D.look_at(player_pos)
			
			var arrow_instance = arrow.instantiate()
			
			arrow_instance.rotation = $Marker2D.rotation
			arrow_instance.global_position = $Marker2D.global_position
			add_child(arrow_instance)
			
			await get_tree().create_timer(20).timeout # Delay between projectile atacks
			bow_cooldown = true
		
	if hurtAnimationPlaying == true:
		velocity *= knockback
	move_and_slide()
	
	if animation_tree["parameters/conditions/hurt"] == true && hurtAnimationPlaying == false:
		animation_tree["parameters/conditions/move"] = true
		animation_tree["parameters/conditions/hurt"] = false
	
	if direction.x > 0.1:
		sprite.flip_h = false
	elif direction.x < -0.1:
		sprite.flip_h = true

func make_path():
	nav_agent.target_position = player.global_position
	if last_position == to_local(nav_agent.get_next_path_position()): 
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
	emit_signal("died")
	queue_free()

func _on_hurt_box_hurt(damage):
	hp -= damage
	DamageNumbers.display_number(damage, damage_numbers_origin.global_position)
	
	snd.stream = load("res://Assets/SoundEffects/hit.wav")
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
	in_range = true
	
	#$Marker2D.look_at(player_pos)

func _on_area_2d_body_exited(body):
	in_range = false

func _on_spawn_timer_timeout():
	#print("bro")
	just_spawned = false
	
#first ranged attack is very inaccurate
