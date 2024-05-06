# https://www.youtube.com/watch?v=Xf2RduncoNU
extends CharacterBody2D

# Stats in data/playerdata to be done
var speed : float = 200
var hp = 100
var experience = 0
var experience_level = 1
var collected_experience = 0
var held_items = []
var x = true

#Represents paused state
var paused

#UI nodes

# Attacks
@onready var weapon = $weapon

# Upgrades
var upgrade_options = []
@onready var inventory = get_tree().get_first_node_in_group("inventory")
signal selected_upgrade(upgrade)

# Stats
var addedStats = {
	"addedPhysical" = 0, 
	"addedMagic" = 0, 
	"addedCrit" = 0,
	"addedAttack Speed" = 0,
	"addedMove Speed" = 0,
	"addedMax Health" = 0
	}

# Enemy Related
var enemy_close = []

@export var starting : Vector2 = Vector2(0, 1)
@onready var animation = $AnimationPlayer/AnimationTree
@onready var sprite = $Sprite2D
@onready var state_machine = animation.get('parameters/playback')

# GUI
@onready var expBar = get_node('%ExperienceBar')
@onready var healthBar = get_node('%HealthBar')
@onready var lblLevel = get_node('%lbl_levelUp')
@onready var levelPanel = get_node('%LevelUp')
@onready var upgradeOptions = get_node('%UpgradeOptions')
@onready var itemOptions = preload("res://Characters/item_option.tscn")
@onready var sndLevelUp = get_node('%snd_levelUp')


func _ready():
	connect("selected_upgrade",Callable(inventory,"upgrade_character"))
	set_expbar(experience, calculate_experiencecap())
	set_healthbar(hp, 100)
	update_animation(starting)
	

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


func _on_hurt_box_hurt(damage, isMagic, isCrit):
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
		levelup()
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
	
func levelup():
	sndLevelUp.play()
	lblLevel.text = str("Level: ",experience_level)
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel,"position",Vector2(442,150),0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	levelPanel.visible = true
	var options = 0
	var optionsmax = 4
	while options < optionsmax:
		var option_choice = itemOptions.instantiate()
		option_choice.item = get_random_item()
		upgradeOptions.add_child(option_choice)
		options += 1
	get_tree().paused = true

func set_healthbar(set_value = 1, set_max_value = 100):
	healthBar.value = set_value
	healthBar.max_value = set_max_value

func upgrade_character(upgrade):
	emit_signal("selected_upgrade",upgrade)
	var option_children = upgradeOptions.get_children()
	for i in option_children:
		i.queue_free()
	levelPanel.visible = false
	levelPanel.position = Vector2(800, 50)
	get_tree().paused = false
	calculate_experience(0)

func get_random_item():
	var randomItem = DataHandler.item_data[str(randi_range(1,5))]
	return randomItem

func update_stats(data):
	for stat in data:
		var statName = "added" + stat
		if statName in addedStats:
			addedStats[statName] += data.get(stat)

		if stat == "Physical":
			var damage = int(data.get(stat)/10)
			weapon.changeWeaponDamage(damage)
		if stat == "Magic":
			var damage = int(data.get(stat)/10)
			weapon.changeMagicDamage(damage)
		if stat == "Attack Speed":
			weapon.changeWeaponSpeed(data.get(stat))
		if stat == "Crit":
			weapon.changeWeaponCrit(data.get(stat))
		if stat == "Move Speed":
			speed += data.get(stat)
		if stat == "Max Health":
			hp += data.get(stat)
	



