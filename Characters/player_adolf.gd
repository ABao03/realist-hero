# https://www.youtube.com/watch?v=Xf2RduncoNU
extends CharacterBody2D

# Stats
var speed : float = 100
var hp = 100
var experience = 0
var experience_level = 1
var collected_experience = 0
var held_items = []

#Represents paused state
var paused

#UI nodes
@onready var pause_screen = $GUILayer/Pausescreen

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

@export var starting : Vector2 = Vector2(0, 1)
@onready var animation = $AnimationPlayer/AnimationTree
@onready var sprite = $Sprite2D
@onready var state_machine = animation.get('parameters/playback')

# GUI
@onready var expBar = get_node('%ExperienceBar')
@onready var healthBar = get_node('%HealthBar')
@onready var lblLevel = get_node('%lbl_level')			
var game_pause
var pause_visibility

func _ready():
	set_expbar(experience, calculate_experiencecap())
	set_healthbar(hp, 100)
	update_animation(starting)
	game_pause = false
	pause_visibility = false
	pause_screen.visible = pause_visibility
	

func _physics_process(_delta):
	var input_direction = Vector2(
		Input.get_action_strength('right') - Input.get_action_strength('left'),
		Input.get_action_strength('down') - Input.get_action_strength('up')
	)
	
	velocity = velocity.normalized()
	velocity = input_direction * speed
		
	move_and_slide()
	new_state()
	
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
		
func new_state():
	if velocity != Vector2.ZERO:
		state_machine.travel('Walk')
	else:
		state_machine.travel('Idle')


func _on_hurt_box_hurt(damage):
	hp -= damage
	if hp == 0:
		get_tree().change_scene_to_file("res://Menu/death.tscn")
	set_healthbar(hp-damage, 100)


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
# If the player gets a chest, add one to the held items variable. 
# These chests will be opened later (I think.)
func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		var collected_item = area.collect()
		
		# Update held items with new chest if chest
		if area.isChest == true:
			held_items.append(area.chestRarity)
		
		# Otherwise, add to EXP bar
		else:
			calculate_experience(collected_item)

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

func set_healthbar(set_value = 1, set_max_value = 100):
	healthBar.value = set_value
	healthBar.max_value = set_max_value


func _input(event: InputEvent):
	#show pause menu
	if (event.is_action_pressed("esc")):

		get_tree().paused = !game_pause
		pause_screen.visible = !pause_visibility
		
		#
		#if pause_screen.visible == false:
			#game_paused = true
			#print("bruh")
			#get_tree().paused = true
			#pause_screen.visible = true	
			#
		#elif pause_screen.visible == true:
			#game_paused = false
			#print("hi")
			#get_tree().paused = false
			#pause_screen.visible = false
			
			
			
			#paused = true
			#pause game     s
			#get_tree().paused = true
			#print("yo")
			#show pause screen popup
			#pause_screen.visible = true
			#stops movement processing 
			#set_physics_process(false)
			#set pauses state to be true
			#
		#elif pause_screen.visible == true:
			#paused = false
			#get_tree().paused = false
			#print("hi")
			#pause_screen.visible = false
			#set_physics_process(true)
			
#Pause menu functions

func _on_resume_pressed():
	get_tree().paused = false
	pause_screen.visible = false

func _on_exit_to_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Menu/menu.tscn")	

func _on_exit_to_desktop_pressed():
	get_tree().quit()





