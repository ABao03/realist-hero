# https://www.youtube.com/watch?v=Xf2RduncoNU

extends CharacterBody2D

# Stats
var speed : float = 100
var hp = 100
var experience = 0
var experience_level = 1
var collected_experience = 0

# Attacks
var iceSpear = preload("res://Characters/Weapons/weapon.tscn") # This has to change if u change the filename

# AttackNodes
@onready var iceSpearTimer = get_node("%IceSpearTimer")
@onready var iceSpearAttackTimer = get_node("%IceSpearAttackTimer")

# IceSpear (change later)
var icespear_ammo = 0
var icespear_baseammo = 1
var icespear_attackspeed = 1.5
var icespear_level = 1

# Enemy Related
var enemy_close = []

# Animation Status
var isAttacking: bool = false

@export var starting : Vector2 = Vector2(0, 1)
@onready var animation = $AnimationPlayer/AnimationTree
@onready var sprite = $Sprite2D
@onready var state_machine = animation.get('parameters/playback')

# GUI
@onready var expBar = get_node('%ExperienceBar')
@onready var lblLevel = get_node('%lbl_level')

func _ready():
	attack()
	set_expbar(experience, calculate_experiencecap())
	update_animation(starting)

func handleInput():
	if Input.is_action_just_pressed("mouse_leftclick"):
		isAttacking = true

func _physics_process(_delta):
	var input_direction = Vector2(
		Input.get_action_strength('right') - Input.get_action_strength('left'),
		Input.get_action_strength('down') - Input.get_action_strength('up')
	)
	
	velocity = velocity.normalized()
	velocity = input_direction * speed
		
	move_and_slide()
	new_state()
	
	handleInput()
	update_animation(input_direction)
	
func update_animation(move_input: Vector2):
	if move_input == Vector2.ZERO:
		animation["parameters/conditions/idle"] = true
		animation["parameters/conditions/walk"] = false
		
	else:
		animation["parameters/conditions/idle"] = false
		animation["parameters/conditions/walk"] = true
		
		animation["parameters/Idle/blend_position"] = move_input
		animation["parameters/Walk/blend_position"] = move_input
	
	if isAttacking == true:
		animation["parameters/conditions/attack"] = true
		isAttacking = false
		
	else:
		animation["parameters/conditions/attack"] = false

func attack():
	if icespear_level > 0:
		iceSpearTimer.wait_time = icespear_attackspeed
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()
		
func new_state():
	if velocity != Vector2.ZERO:
		state_machine.travel('Walk')
	else:
		state_machine.travel('Idle')


func _on_hurt_box_hurt(damage):
	hp -= damage
	if hp == 0:
		get_tree().change_scene_to_file("res://Menu/death.tscn")
	print(hp)


func _on_ice_spear_timer_timeout():
	pass # Replace with function body.


func _on_ice_spear_attack_timer_timeout():
	pass

# Changes the target variable inside of the xp drop from null to the player. 
# So, the xp drop is pulled towards the player. 
func _on_grab_area_area_entered(area):
	if area.is_in_group("loot"):
		area.target = self

# Run the collect function inside of the xp drop.
# Collect function plays the xp collected sound and provides the xp to the player.
func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_experience(gem_exp)

func calculate_experience(gem_exp):
	var exp_required = calculate_experiencecap()
	collected_experience += gem_exp
	if experience + collected_experience >= exp_required: #level up
		collected_experience -= exp_required-experience
		experience_level += 1
		lblLevel.text = str("Level: ", experience_level)
		experience = 0
		exp_required = calculate_experiencecap()
		calculate_experience(0)
		# levelup()
	else:
		experience += collected_experience
		collected_experience = 0
	
	set_expbar(experience, exp_required)	
	
# Calculate experience needed to level up each time
func calculate_experiencecap():
	var exp_cap = experience_level
	if experience_level < 20:
		exp_cap = experience_level*5
	elif experience_level < 40:
		exp_cap + 95 * (experience_level-19)*8
	else:
		exp_cap = 255 + (experience_level-39)*12
		
	return exp_cap

func set_expbar(set_value = 1, set_max_value = 100):
	expBar.value = set_value
	expBar.max_value = set_max_value
