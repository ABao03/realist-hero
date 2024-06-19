# https://www.youtube.com/watch?v=Xf2RduncoNU
extends CharacterBody2D

# Stats in data/playerdata to be done
@export var speed : float = 150
@onready var collision = $CollisionShape2D
@onready var maxhp = 100
@onready var hpPercent = 1.00
@onready var acc: int = 0

var experience = 0
var experience_level = 1
var collected_experience = 0
var held_items = []
var x = true
@onready var button_clicked = get_node("Sprint")

# Movement
@onready var axis = Vector2.ZERO

#Represents paused state
var paused
var playerPaused = false

# Sounds
@onready var playerSnd = $Snd
@onready var abilitySnd = $AbilitySnd

# Attacks
@onready var attackBox1 = $HitBox
@onready var attackBox2 = $HitBox2
var boxesFlipped = false

# Abilities
@onready var damageAbility = $UltButton
@onready var ultimateAbility = $AbilityButton
@onready var abilityDuration = $AbilityDuration
@onready var indicator = $Indicator

@onready var abilityEffects = get_tree().get_first_node_in_group("ability")

var usingAbility = false
var heldAbility = null

# Recalling
var playerRecalling = false
@onready var recallDuration = $RecallDuration
@onready var recall = $Recall

# Upgrades
var upgrade_options = []
@onready var inventory = get_tree().get_first_node_in_group("inventory")
signal selected_upgrade(upgrade)
signal stop_spawning()

# ranged attack
var bow_equipped = false
var bow_cooldown = true
var arrow_shot = false
var arrow = preload("res://Characters/arrow.tscn")

# Enemy Related
@onready var spawner = get_tree().get_first_node_in_group("spawner")

@export var starting : Vector2 = Vector2(0, 1)
@onready var animation = $AnimationPlayer
@onready var animation_tree = $AnimationTree
@onready var sprite = $Sprite2D

# GUI
@onready var recallBar = get_node('%RecallBar')
@onready var expBar = get_node('%ExperienceBar')
@onready var healthBar = get_node('%HealthBar')
@onready var lblLevel = get_node('%lbl_levelUp')
@onready var levelPanel = get_node('%LevelUp')
@onready var upgradeOptions = get_node('%UpgradeOptions')
@onready var itemOptions = preload("res://Characters/item_option.tscn")
@onready var sndLevelUp = get_node('%snd_levelUp')


func _ready():
	connect("selected_upgrade",Callable(inventory,"upgrade_character"))
	connect("stop_spawning",Callable(spawner,"stop_spawns"))
	set_expbar(experience, calculate_experiencecap())
	animation_tree.active = true
	set_healthbar(maxhp*hpPercent, maxhp)
	#modulate = Color(1, 1, 1, 1)

func _physics_process(delta):
	var thisSpeed = speed * 100
	velocity = delta * thisSpeed * axis
	
	axis.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")) 
	axis.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up")) 
	
	if Input.is_action_just_pressed("recall"):
		if playerRecalling == true:
			playerRecalling = false
			cancel_recall()
		else:
			playerRecalling = true
			recallBar.visible = true
			recallDuration.start()
			recall.visible = true
	
	# Movement stuff
	if playerPaused == false && playerRecalling == false:
		if Input.is_action_just_pressed("switch"):
			if bow_equipped == true:
				bow_equipped = false
			else:
				bow_equipped = true
		
	# Ability pressed stuff
		if Input.is_action_just_pressed("damage_ability"):
			if damageAbility.onCooldown == false:
				indicator.visible = true
				heldAbility = damageAbility
		elif Input.is_action_just_pressed("ultimate_ability"):
			if ultimateAbility.onCooldown == false:
				indicator.visible = true
				heldAbility = ultimateAbility
		
		if Input.is_action_pressed("mouse_leftclick"):
			if heldAbility != null && usingAbility == false:
				player_ability_used(heldAbility)
				usingAbility = true
				
			elif bow_equipped and bow_cooldown:
				bow_cooldown = false
				var arrow_instance = arrow.instantiate()
				arrow_instance.rotation = $Marker2D.rotation
				arrow_instance.global_position = $Marker2D.global_position
				add_child(arrow_instance)
				
				await get_tree().create_timer(1).timeout
				bow_cooldown = true
				
			elif bow_equipped == false:
				if animation_tree.get("parameters/playback").get_current_node() != "attack":
					playerSnd.stream = load("res://Assets/SoundEffects/swing.wav")
					playerSnd.play()
				animation_tree["parameters/conditions/swing"] = true
		else:
			animation_tree["parameters/conditions/swing"] = false
			
			if velocity == Vector2.ZERO:
				animation_tree["parameters/conditions/idle"] = true
				animation_tree["parameters/conditions/is_moving"] = false
			else:
				animation_tree["parameters/conditions/idle"] = false
				animation_tree["parameters/conditions/is_moving"] = true
				if playerSnd.is_playing() == false:
					playerSnd.stream = load("res://Assets/SoundEffects/footstep.mp3")
					playerSnd.pitch_scale = 0.75
					playerSnd.play()
				
			var mouse_pos = get_global_mouse_position()
			$Marker2D.look_at(mouse_pos)
		
		if axis.x > 0:
			sprite.flip_h = false
		elif axis.x < 0:
			sprite.flip_h = true
		else:
			if sprite.flip_h == true:
				sprite.flip_h = true
			else:
				sprite.flip_h = false
		
		if animation_tree.get("parameters/playback").get_current_node() == "attack":
			velocity = velocity/3
		
		move_and_slide()
		
		if sprite.flip_h == true && boxesFlipped == false:
			attackBox1.position -= Vector2(28,0)
			attackBox2.position -= Vector2(58,0)
			boxesFlipped = true
		if sprite.flip_h == false && boxesFlipped == true:
			attackBox1.position += Vector2(28,0)
			attackBox2.position += Vector2(58,0)
			boxesFlipped = false
	
	# Switch player to idle if not moving
	if playerPaused == true:
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
		animation_tree["parameters/conditions/swing"] = false
	
	# handle recall
	if playerRecalling == true:
		set_recallbar(5-recallDuration.time_left)

func _on_hurt_box_hurt(damage, isMagic, isCrit):
	var percentDamageTaken = float(damage)/float(maxhp)
	hpPercent -= percentDamageTaken
	if hpPercent <= 0:
		get_tree().change_scene_to_file("res://Menu/death.tscn")
	set_healthbar(maxhp*hpPercent, maxhp)
	if playerRecalling == true:
		cancel_recall()

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
		
		experience = 0
		exp_required = calculate_experiencecap()
		#levelup()
		acc += 1
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

func set_recallbar(set_value = 0):
	recallBar.value = set_value

func levelup():
	emit_signal("stop_spawning")
	sndLevelUp.play()
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
	

func set_healthbar(hp, set_max_value):
	healthBar.max_value = set_max_value
	healthBar.value = hp

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
	var randomItem = DataHandler.item_data[str(randi_range(1,8))]
	return randomItem

func update_stats(data):
	for stat in data:
		# NOTE: THESE SHOULD ALL BE CHANGED TO SETTERS, NOT ADDER/MULTIPLIER
		# This logic is all being moved to recalculate stats in Inventory
		if stat == "Physical":
			attackBox1.damage = data.get(stat)
			attackBox2.damage = data.get(stat)
			
		if stat == "Magic":
			attackBox1.magicDamage = data.get(stat)
			attackBox2.magicDamage = data.get(stat)
			
		if stat == "Attack Speed":
			var currentSpeed = animation.speed_scale
			animation.speed_scale = currentSpeed * data.get(stat)
			
		if stat == "Crit":
			attackBox1.crit = data.get(stat) - 1
			attackBox2.crit = data.get(stat) - 1
			
		if stat == "Move Speed":
			speed = data.get(stat)
				
		if stat == "Max Health":
			maxhp = data.get(stat)
			set_healthbar(maxhp*hpPercent, maxhp)
			
		if stat == "Defense":
			pass

# Make it so chest is only openable when you level up
func _on_button_pressed():
	if acc > 0:
		inventory.open()
		acc -= 1
		levelup()
		
	
func player_ability_used(ability):
	if ability.abilityType == "dmg":
		abilityDuration.wait_time = 0.45
		abilitySnd.stream = load("res://Assets/SoundEffects/thunder.mp3")
		abilitySnd.play()
		abilityDuration.start()
		abilityEffects.ability_used(get_global_mouse_position(), attackBox1.magicDamage + attackBox2.magicDamage)
		
	elif ability.abilityType == "ult":
		abilityDuration.wait_time = 2
		abilityDuration.start()
		abilityEffects.ult_used(global_position, attackBox1.magicDamage + attackBox2.magicDamage)
		# ability effects handles the actual slash effect
	
	indicator.visible = false

func _on_ability_duration_timeout():
	heldAbility.activated()
	heldAbility = null
	usingAbility = false

func _on_recall_duration_timeout():
	get_tree().change_scene_to_file("res://Worlds/Hub World/hubworld.tscn")
	cancel_recall()

func cancel_recall():
	playerRecalling = false
	recall.visible = false
	recallBar.visible = false
	recallDuration.stop()
