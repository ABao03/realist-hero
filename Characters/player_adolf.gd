# https://www.youtube.com/watch?v=Xf2RduncoNU
extends CharacterBody2D

# Stats in data/playerdata to be done
@export var speed : float = 125
@onready var collision = $CollisionShape2D
#@onready var chest_sprite = get_tree().get_first_node_in_group("chest")
@onready var animation_player: bool = true


@onready var maxhp = 100
@onready var hpPercent = 1.00
@onready var acc: int = 0

@onready var experience = 0
@onready var experience_level = 1
var collected_experience = 0
var held_items = []
var x = true

# Movement
@onready var axis = Vector2.ZERO
var lastDirectionVector : Vector2

#Represents paused state
var playerPaused = false
var playerDead = false

# Sounds
@onready var playerSnd = $Snd
@onready var abilitySnd = $AbilitySnd

# Attacks
@onready var weapon = $Weapon

# Abilities
@onready var damageAbility = $UltButton
@onready var ultimateAbility = $AbilityButton
@onready var abilityDuration = $AbilityDuration
@onready var indicator = $Indicator

@onready var abilityEffectsGroup = get_tree().get_nodes_in_group("ability")
var abilityEffects

var usingAbility = false
var heldAbility

# Recalling
var playerRecalling = false
@onready var recallDuration = $RecallDuration
@onready var recall = $Recall

# Upgrades
var upgrade_options = []
@onready var inventoryGroup = get_tree().get_nodes_in_group("inventory")
var inventory
signal selected_upgrade(upgrade)

# ranged attack
var bow_equipped = false
var bow_cooldown = true
var arrow_shot = false
var arrow = preload("res://Characters/arrow.tscn")

# Enemy Related
@onready var spawner = get_tree().get_first_node_in_group("spawner")
signal despawn_enemies()
signal pause_spawning()

@export var starting : Vector2 = Vector2(0, 1)
@onready var animation = $AnimationPlayer
#@onready var animation_tree = $AnimationTree
@onready var sprite = $Sprite2D
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
@onready var ambientLight = $PointLight2D3
@onready var shadow = $PointLight2D2

func _ready():
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
			
	connect("selected_upgrade",Callable(inventory,"upgrade_character"))
	connect("despawn_enemies",Callable(spawner,"despawn_enemies"))
	connect("pause_spawning",Callable(spawner,"pause_spawning"))

func _exit_tree():
	remove_from_group("player")

func _physics_process(delta):
	var thisSpeed = speed * 100
	velocity = delta * thisSpeed * axis
	
	axis.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")) 
	axis.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up")) 
	
	if Input.is_action_just_pressed("recall"):
		if playerRecalling == true:
			maxhp = 1 # debug
			playerRecalling = false
			cancel_recall()
		else:
			playerRecalling = true
			#recallBar.visible = true
			recallDuration.start()
			#recall.visible = true
	
	# Movement stuff
	if playerPaused == false: # && playerRecalling == false
		velocity.normalized()
		#if Input.is_action_just_pressed("switch"):
			#if bow_equipped == true:
				#bow_equipped = false
			#else:
				#bow_equipped = true
		
	# Ability pressed stuff
		if Input.is_action_just_pressed("damage_ability"):
			if damageAbility.onCooldown == false:
				indicator.visible = true
				player_ability_used(damageAbility)
				heldAbility = damageAbility
				usingAbility = true
		elif Input.is_action_just_pressed("ultimate_ability"):
			if ultimateAbility.onCooldown == false:
				indicator.visible = true
				player_ability_used(ultimateAbility)
				heldAbility = ultimateAbility
				usingAbility = true
		
		if Input.is_action_pressed("mouse_leftclick"):
			# if no ability equipped, use arrow
			if bow_equipped and bow_cooldown:
				bow_cooldown = false
				var arrow_instance = arrow.instantiate()
				arrow_instance.rotation = $Marker2D.rotation
				arrow_instance.global_position = $Marker2D.global_position
				add_child(arrow_instance)
				
				await get_tree().create_timer(1).timeout
				bow_cooldown = true
			
			# if no bow equipped, use melee attack
			elif bow_equipped == false:
				if animation.current_animation != "attack":
				#animation_tree["parameters/conditions/swing"] = true
					animation.play("attack")
					weapon.attack()
		#else:
			#animation_tree["parameters/conditions/swing"] = false
			
		if velocity == Vector2.ZERO:
			#animation_tree["parameters/conditions/idle"] = true
			#animation_tree["parameters/conditions/is_moving"] = false
			animation.play("idle")
		else:
			lastDirectionVector = velocity
			#animation_tree["parameters/conditions/idle"] = false
			#animation_tree["parameters/conditions/is_moving"] = true
			if animation.current_animation != "walk":
				animation.play("walk")
			if playerSnd.is_playing() == false:
				playerSnd.stream = load("res://Assets/SoundEffects/footstep.mp3")
				playerSnd.pitch_scale = 0.75
				playerSnd.play()
			#sprite.flip_h = true
		#else:
			#if sprite.flip_h == true:
				#sprite.flip_h = true
			#else:
				#sprite.flip_h = false
		
		var mouse_pos = get_global_mouse_position()
		sprite.look_at(mouse_pos)
		sprite.rotation += PI/2
		#sprite.rotation = velocity.angle() + PI/2
		
		#if animation_tree.get("parameters/playback").get_current_node() == "":
		#if animation.current_animation == "attack":
			#velocity = velocity/3
		
		move_and_slide()
		
		# Old code for not-top-down view
		#if sprite.flip_h == true && boxesFlipped == false:
			#attackBox1.position -= Vector2(28,0)
			#attackBox2.position -= Vector2(58,0)
			#boxesFlipped = true
		#if sprite.flip_h == false && boxesFlipped == true:
			#attackBox1.position += Vector2(28,0)
			#attackBox2.position += Vector2(58,0)
			#boxesFlipped = false
	
	# Switch player to idle if not moving
	if playerPaused == true:
		#animation_tree["parameters/conditions/idle"] = true
		#animation_tree["parameters/conditions/is_moving"] = false
		#animation_tree["parameters/conditions/swing"] = false
		animation.stop()
		animation.play("idle")
	
	# handle recall
	if playerRecalling == true:
		set_recallbar(5-recallDuration.time_left)

func _on_hurt_box_hurt(damage, isMagic, isCrit):
	var percentDamageTaken = float(damage)/float(maxhp)
	hpPercent -= percentDamageTaken
	if hpPercent <= 0 && playerDead == false:
		playerPaused = true
		playerDead = true
		SceneManager.load_new_scene("res://Menu/death.tscn","fade_to_black")
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

func set_recallbar(set_value = 0):
	recallBar.value = set_value

func levelup():
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
	sndLevelUp.play()
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel,"position",Vector2(600,100),0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
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
			weapon.set_physical(data.get(stat))
			
		if stat == "Magic":
			weapon.set_magic(data.get(stat))
			
		if stat == "Attack Speed":
			var currentSpeed = animation.speed_scale
			animation.speed_scale = currentSpeed * data.get(stat)
			
		if stat == "Crit":
			weapon.set_crit(data.get(stat) - 1)
			
		if stat == "Move Speed":
			speed = data.get(stat)
				
		if stat == "Max Health":
			maxhp = data.get(stat)
			set_healthbar(maxhp*hpPercent, maxhp)
			
		if stat == "Defense":
			pass

# Make it so chest is only openable when you level up
#func _on_button_pressed():
#
	#if acc > 0: #When the player levels up
		#acc -= 1
		#chest_sprite.play("Open") #Play the animation of the chest opening
		#await get_tree().create_timer(1).timeout #waits 0.65s 
		#chest_sprite.stop() #stop animation
#
		#inventory.open() #Open inventory menu
		#levelup()
		#var exp_required = calculate_experiencecap()
		#experience = 0
		#experience_level += 1
		#exp_required = calculate_experiencecap()
		#expBar.modulate = Color(1,1,1,1)
		#
		## LEO add function to switch chest sprite to closed
		#
	#else: #When the player did not level up
		#chest_sprite.play("Idle_clicked") #Play the idle animation
		#await get_tree().create_timer(1).timeout
		#chest_sprite.stop()
		
	
func player_ability_used(ability):
	if ability.abilityType == "dmg":
		abilityDuration.wait_time = 0.45
		abilitySnd.stream = load("res://Assets/SoundEffects/fireball.wav")
		abilitySnd.play()
		abilityDuration.start()
		abilityEffects.ability_used(global_position, weapon.get_magic())
		
	elif ability.abilityType == "ult":
		abilityDuration.wait_time = 2
		abilityDuration.start()
		abilityEffects.ult_used(global_position, weapon.get_magic())
		# ability effects handles the actual slash effect
	
	indicator.visible = false

func _on_ability_duration_timeout():
	# activates the cooldown button
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

func disable_light():
	pointLight.visible = false
