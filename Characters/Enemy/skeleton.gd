extends CharacterBody2D

var movement_speed = 25.0
var enemy_type = 0

var maxHealth = 200
var health = maxHealth
var dead = false

var experience = 3
@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var sprite = $Skeleton
@onready var damage_numbers_origin = $DamageNumbers
@onready var hitbox = $HitBox/CollisionShape2D
@onready var damage = $HitBox.damage

@onready var snd = $Snd

var loot = preload("res://Characters/Enemy/Drops/loot_drop.tscn")

var player_chase = false
var player_presence = null

@onready var spawner = get_tree().get_first_node_in_group("spawner")
signal died()

func _ready():
	connect("died",Callable(spawner,"on_enemy_death"))

func _physics_process(_delta):
	$HitBox.damage = damage
	var direction = global_position.direction_to(player.global_position)
	velocity = direction*movement_speed
	move_and_slide()
	$Skeleton.play("Walking")
	
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
	emit_signal("died", enemy_type) 
	
	# Skeleton died but don't queue free yet because we need to play the sound
	dead = true
	hitbox.disabled = true
	sprite.visible = false
	
	snd.stream = load("res://Assets/SoundEffects/skeleton_death.wav")
	snd.play()

func _on_hurt_box_hurt(damage):
	snd.stream = load("res://Assets/SoundEffects/skeleton_hit.mp3")
	snd.play()
	health -= damage
	DamageNumbers.display_number(damage, damage_numbers_origin.global_position)
	if health <= 0:
		death()

func _on_snd_finished():
	if dead == true:
		queue_free()
