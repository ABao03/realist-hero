extends CharacterBody2D

@export var movement_speed = 100.0
@export var hp = 100
@export var experience = 1
@export var knockback = -5

@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var last_position = Vector2(0,0)
@onready var sprite = $Slime
@onready var damage_numbers_origin = $DamageNumbers
@onready var damage = $HitBox.damage

@onready var snd = $Snd
@onready var animation_tree = $AnimationTree
@onready var hurtAnimationPlaying = false

var dead = false
@onready var hitbox = $HitBox/CollisionShape2D

var loot = preload("res://Characters/Enemy/Drops/loot_drop.tscn")

@onready var spawner = get_tree().get_first_node_in_group("spawner")
signal died()

func _ready():
	sprite.visible = false
	connect("died",Callable(spawner,"on_enemy_death"))

# Moving slime around 
func _physics_process(_delta):
	$HitBox.damage = damage
	
	var direction = to_local(nav_agent.get_next_path_position()).normalized()
	sprite.look_at(player.global_position)
	sprite.rotation -= PI / 2
	
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
	if last_position == to_local(nav_agent.get_next_path_position()): 
		emit_signal("died")
		queue_free()
	if last_position != Vector2(0,0) && dead == false:
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
	
	# Slime died but don't queue free yet because we need to play the sound
	dead = true
	hitbox.disabled = true
	sprite.visible = false
	
	snd.stream = load("res://Assets/SoundEffects/slime_death.mp3")
	snd.play()

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
	#print(player.global_position)
	pass

# Wait for sound to finish before queue freeing
func _on_snd_finished():
	if dead == true:
		queue_free()
