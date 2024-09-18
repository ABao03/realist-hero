extends CharacterBody2D

@export var movement_speed = 70.0
@export var hp = 60
@export var experience = 1
@export var knockback = -5
var enemy_type = 1

@onready var players = get_tree().get_nodes_in_group("player")
var player
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
#var bow_cooldown = true
#var arrow_shot = false
#var arrow = preload("res://Characters/Enemy/throw.tscn")
var theta : float = 0.0
@export_range(0,2*PI) var alpha : float = 0.0
var bullet_node = preload("res://Characters/Enemy/enemy_bullet.tscn")
var yinBullet = false

@onready var spawner = get_tree().get_first_node_in_group("spawner")
signal died()

func _ready():
	for thisPlayer in players:
		if thisPlayer != null:
			player = thisPlayer
	
	$SpawnTimer.start()
	connect("died",Callable(spawner,"on_enemy_death"))

# Moving slime around 
func _physics_process(_delta):
	var direction = to_local(nav_agent.get_next_path_position()).normalized()
	
	velocity = direction * movement_speed
		
	if in_range == true and just_spawned == false:
		velocity = Vector2(0.01,0.01)
		
	await get_tree().create_timer(5).timeout # Delay between projectile atacks
			#bow_cooldown = true
		
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

func _on_area_2d_body_entered(body):
	in_range = true

func _on_area_2d_body_exited(body):
	in_range = false

func _on_spawn_timer_timeout():
	just_spawned = false

func get_vector(angle):
	theta = angle + alpha
	return Vector2(cos(theta),sin(theta))

func shoot(angle):
	var bullet = bullet_node.instantiate()
	
	bullet.position = global_position
	bullet.direction = get_vector(angle)
	
	get_tree().current_scene.call_deferred("add_child", bullet)

func _on_speed_timeout():
	shoot(theta)
