# https://www.youtube.com/watch?v=Xf2RduncoNU
extends CharacterBody2D

# Stats in data/playerdata to be done
@export var speed : float = 150
@onready var collision = $CollisionShape2D
@onready var maxhp = 100
var hp = 100
@onready var acc: int = 0

var experience = 0
var experience_level = 1
var collected_experience = 0
var held_items = []
var x = true

# Movement
@onready var axis = Vector2.ZERO

#Represents paused state
var paused
var playerPaused = false

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
	"addedMax Health" = 0,
	"addedDefense" = 0
	}

# Enemy Related
var enemy_close = []

@export var starting : Vector2 = Vector2(0, 1)
@onready var animation = $AnimationPlayer
@onready var sprite = $Sprite2D

# GUI
@onready var expBar = get_node('%ExperienceBar')
@onready var expBarLbl = get_node('%lbl_level')
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

func _physics_process(delta):
	if playerPaused == false:
		axis.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")) 
		axis.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up")) 
		
		var thisSpeed = speed * 100
		velocity = delta * thisSpeed * axis
		
		if velocity == Vector2.ZERO:
			if sprite.flip_h == true:
				animation.play("idle_left")
			else:
				animation.play("idle_right")
		else:
			if axis.x > 0:
				sprite.flip_h = false
			elif axis.x < 0:
				sprite.flip_h = true
			else:
				if sprite.flip_h == true:
					sprite.flip_h = true
				else:
					sprite.flip_h = false
			animation.play("walk")
			
		move_and_slide()

func _on_hurt_box_hurt(damage, isMagic, isCrit):
	hp -= damage
	if hp == 0 or hp < 0:
		get_tree().change_scene_to_file("res://Menu/death.tscn")
	set_healthbar(hp-damage, 100)

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
		expBarLbl.text = lblLevel.text
		
		experience = 0
		exp_required = calculate_experiencecap()
		#levelup()
		acc += 1
		print(acc)
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
	var randomItem = DataHandler.item_data[str(randi_range(1,13))]
	return randomItem

func update_stats(data):
	for stat in data:
		var statName = "added" + stat
		if statName in addedStats:
			addedStats[statName] += data.get(stat)

		if stat == "Physical":
			var damage = data.get(stat)
			if damage > 2:
				damage = int(damage/10)
			else:
				pass
			weapon.changeWeaponDamage(damage)
		if stat == "Magic":
			var damage = data.get(stat)
			if data.get(stat) > 2:
				damage = int(damage/10)
			else:
				pass
			weapon.changeMagicDamage(damage)
		if stat == "Attack Speed":
			weapon.changeWeaponSpeed(data.get(stat))
		if stat == "Crit":
			weapon.changeWeaponCrit(data.get(stat))
		if stat == "Move Speed":
			if float(stat) > 2:
				speed += data.get(stat)
			else:
				speed *= data.get(stat)
		if stat == "Max Health":
			if float(stat) > 2:
				hp += data.get(stat)
			else:
				hp *= data.get(stat)
		if stat == "Defense":
			pass
	





func _on_button_pressed():
	if acc > 0:
		acc -= 1
		levelup()
