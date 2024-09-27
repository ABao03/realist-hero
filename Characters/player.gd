# https://www.youtube.com/watch?v=Xf2RduncoNU
extends CharacterBody2D

# Stats in data/playerdata to be done
@export var speed : float = 300
@export var acceleration : float = 1000.0
@onready var collision = $CollisionShape2D
@onready var animation_player: bool = true
@onready var graze_area = $GrazeArea

@onready var maxhp = 100
@onready var hpPercent = 1.00
@onready var acc: int = 0

@onready var experience = 0
@onready var experience_level = 1
var collected_experience = 0
var held_items = []
var startItemCollected = false

# Movement
@onready var axis = Vector2.ZERO
var lastDirectionVector : Vector2

# Represents paused state
var playerPaused = false
var playerDead = false

# Sounds
@onready var playerSnd = $Snd
@onready var abilitySnd = $AbilitySnd

@onready var indicator = $Indicator

@onready var abilityEffectsGroup = get_tree().get_nodes_in_group("ability")
var abilityEffects

var usingAbility = false
var heldAbility

# Upgrades
var upgrade_options = []
@onready var inventoryGroup = get_tree().get_nodes_in_group("inventory")
var inventory
signal selected_upgrade(upgrade)

# Enemy Related
@onready var spawner = get_tree().get_first_node_in_group("spawner")
@onready var slime = get_tree().get_first_node_in_group("slime")
signal despawn_enemies()
signal pause_spawning()
signal player_level_up()

@onready var animation = $AnimationPlayer
@onready var hitFlashAnim = $HitFlashAnimation
#@onready var animation_tree = $AnimationTree
@onready var sprite = $PlayerSprite
var signal_emitted = false

# GUI
@onready var recallBar = get_node('%RecallBar')
@onready var expBar = get_node('%ExperienceBar')
@onready var healthBar = get_node('%HealthBar')
@onready var lblLevel = get_node('%lbl_levelUp')
@onready var levelPanel = get_node('%LevelUp')
@onready var upgradeOptions = get_node('%UpgradeOptions')
@onready var itemOptions = preload("res://Characters/item_option.tscn")
@onready var sndLevelUp = get_node('%snd_levelUp')

# Light stuff
@onready var pointLight = $PointLight2D
var shaderEnabled : bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	set_expbar(experience, calculate_experiencecap())
	#animation_tree.active = true
	set_healthbar(maxhp*hpPercent, maxhp)
	#modulate = Color(1, 1, 1, 1)
	
	for abilityEffect in abilityEffectsGroup:
		if abilityEffect != null:
			abilityEffects = abilityEffect
	
	for inven in inventoryGroup:
		if inven != null:
			inventory = inven
			
	connect("selected_upgrade", Callable(inventory, "upgrade_character"))
	connect("despawn_enemies", Callable(spawner, "despawn_enemies"))
	connect("pause_spawning", Callable(spawner, "pause_spawning"))
	
	connect("player_level_up", Callable(spawner, "player_level_up"))

func _exit_tree():
	remove_from_group("player")

func _physics_process(delta):
	axis.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")) 
	axis.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	
	# Movement stuff
	if playerPaused == false:
		var desired_velocity = axis.normalized() * speed
		velocity = velocity.move_toward(desired_velocity, acceleration * delta)
		if axis == Vector2.ZERO:
			velocity = Vector2.ZERO
		
		if axis.x < 0 and velocity.length() > 0:
			sprite.flip_h = true
		elif axis.x > 0 and velocity.length() > 0:
			sprite.flip_h = false 
		
		if velocity.length() == 0:
			animation.play("idle")
		else:
			lastDirectionVector = velocity
			if animation.current_animation != "walk":
				animation.play("walk")
			if playerSnd.is_playing() == false:
				playerSnd.stream = load("res://Assets/SoundEffects/footstep.mp3")
				playerSnd.pitch_scale = 0.75
				playerSnd.play()
		
		move_and_slide()

		
	if playerPaused == true:
		animation.stop()
		animation.play("idle")

func _on_hurt_box_hurt(damage):
	var percentDamageTaken = float(damage)/float(maxhp)
	hpPercent -= percentDamageTaken
	if hpPercent <= 0 && playerDead == false:
		playerPaused = true
		playerDead = true
		SceneManager.load_new_scene("res://Menu/death.tscn","fade_to_black")
	set_healthbar(maxhp*hpPercent, maxhp)
	hitFlashAnim.play("hurt")
	playerSnd.stream = load("res://Assets/SoundEffects/crit_hit.mp3")
	playerSnd.play()

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

# When bullets (and only bullets) graze, add xp
# if you want enemy graze, you have to get_overlapping_bodies
func check_graze_area():
	var overlapping_areas = graze_area.get_overlapping_areas()
	if startItemCollected == false:
		if get_tree().current_scene.name == "Random-world":
			levelup()
			startItemCollected = true
			experience_level -= 1
	elif overlapping_areas.size() > 0:
		calculate_experience(calculate_experiencecap()*0.02)

func calculate_experience(gem_exp):
	var exp_required = calculate_experiencecap()
	collected_experience += gem_exp
	if experience + collected_experience >= exp_required && acc == 0: # when xp bar is full, keep it at max. Reset when chest clicked
		experience = exp_required
		expBar.modulate = Color(0, 100, 0, 1)
		#acc += 1
		levelup()
		collected_experience = 0
	elif experience == exp_required && acc > 0:
		return
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
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	indicator.visible = false
	# level up right away code
	inventory.open() #Open inventory menu
	var exp_required = calculate_experiencecap()
	experience = 0
	experience_level += 1
	exp_required = calculate_experiencecap()
	expBar.modulate = Color(1,1,1,1)
	
	# code that exists outside of levelling up right away
	signal_emitted = true
	emit_signal("despawn_enemies")
	emit_signal("pause_spawning")
	emit_signal("player_level_up")
	sndLevelUp.play()
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel,"position",Vector2(600,100),0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	levelPanel.visible = true
	var optionsmax = 4
	var currentOptions = []
	while currentOptions.size() < optionsmax:
		var foundDupe = false
		var option_choice = itemOptions.instantiate()
		option_choice.item = get_random_item()
		for choice in currentOptions:
			#print(option_choice.item.get("Name"))
			#print(choice.item.get("Name"))
			#print('\n')
			if option_choice.item.get("Name") == choice.item.get("Name"):
				foundDupe = true
		if foundDupe == false:
			upgradeOptions.add_child(option_choice)
			currentOptions.append(option_choice)
		
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
	var randomItem = DataHandler.item_data[str(randi_range(1,7))]
	return randomItem

func update_stats(data):
	pass

func disable_light():
	pointLight.visible = false

func _on_level_up_debug_button_pressed():
	calculate_experience(calculate_experiencecap())

func _on_graze_detect_timer_timeout():
	check_graze_area()
