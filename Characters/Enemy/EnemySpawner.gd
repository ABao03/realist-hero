extends Node2D

# Hold array of currently alive enemies 
@export var spawns: Array[Spawn_info] = []

# Call player node from scene
@onready var players = get_tree().get_nodes_in_group("player")
var player

# Get enemy nodes
@onready var slime = get_tree().get_first_node_in_group("slime")
@onready var skeleton = get_tree().get_first_node_in_group("skeleton")
@onready var enemy = preload("res://Characters/Enemy/ranged_boss.tscn")

var spawn_circle = load("res://Assets/Images/Enemy Assets/spawn_circle.png")

# Delay between spawns (I think)
@onready var timer = $Timer
@onready var timer_2 = $Dragon_Timer

@onready var dragon_spawned: bool = false

#keeps track of number of enemies
var basic_enemy_counter = 0
var ranged_enemy_counter = 0
var basic_enemy_cap
var ranged_enemy_cap
var basic_enemy_id_list = [0,1]
var ranged_enemy_id_list = [2]
#signal changetime(time)

#Keeps track of scaling
@onready var leveled_up: bool = false

func _ready():
	#connect("changetime",Callable(player,"change_time"))
	for thisPlayer in players:
		if thisPlayer != null:
			player = thisPlayer

func spawn_wave():
	var enemy_spawns = spawns
	while basic_enemy_counter < basic_enemy_cap: # when the number of enemies is smaller than the enemy cap
		# removed spawn delay counter
		
		# randomly generate a new enemy using the basic enemy id list (this will need to be manually updated probably)
		var new_enemy = spawns[int(randf_range(0, basic_enemy_id_list.size()))].enemy
		var enemy_spawn = new_enemy.instantiate()
		telegraph_spawn(enemy_spawn)
		
		basic_enemy_counter += 1 # number of basic enemies gets incremeneted
	
	# emit_signal("changetime",time)
	scaling(slime)
	scaling(skeleton)
	
	while ranged_enemy_counter < ranged_enemy_cap: # when the number of enemies is smaller than the enemy cap
		# randomly generate a new enemy using the ranged enemy id list (this will need to be manually updated probably)
		var new_enemy = spawns[int(randf_range(0, ranged_enemy_id_list.size()))].enemy
		var enemy_spawn = new_enemy.instantiate()
		telegraph_spawn(enemy_spawn)
		
		ranged_enemy_counter += 1 # number of basic enemies gets incremeneted

func telegraph_spawn(enemy):
	enemy.global_position = get_random_position()
	var spawn_indicator = Sprite2D.new()
	spawn_indicator.texture = spawn_circle
	spawn_indicator.global_position = enemy.global_position
	add_child(spawn_indicator)
	
	# Set a timer to delete the red circle after 3 seconds
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.one_shot = true
	spawn_indicator.add_child(timer)
	timer.timeout.connect(func() -> void:
		spawn_indicator.queue_free()  # Remove the red circle after 3 seconds
		add_child(enemy)
	)
	# Start the timer
	timer.start()

# NOTE: DEPRECATE!
# When timer hits 0, run this code
func _on_timer_timeout():
	var player_level = player.experience_level
	#enemy_cap = 7 + player_level*2 #max number of enemies per level
	if player_level == 1:
		basic_enemy_cap = 0
		ranged_enemy_cap = 1
	elif player_level == 2:
		basic_enemy_cap = 7
		ranged_enemy_cap = 2
	elif player_level == 3:
		basic_enemy_cap = 12
		ranged_enemy_cap = 2
	elif player_level == 4:
		basic_enemy_cap = 15
		ranged_enemy_cap = 3
		
	spawn_wave()
	
	if player.experience_level == 5 and get_tree().current_scene.name != "Tutorial_World" and dragon_spawned == false:
		dragon_spawned = true
		dragon_spawn()

func dragon_spawn():
	timer.stop()
	for bruh in get_children():
		if bruh.is_in_group("enemy"):
			bruh.queue_free()
			#print(player.experience_level)
	var enemy_instance = enemy.instantiate()
	enemy_instance.global_position =Vector2(-450,-212)
	add_child(enemy_instance)

# Randomly generate the enemy's position based on where the player is at 
func get_random_position():
	var vpr = get_viewport_rect().size * randf_range(1.1,1.4)
	var top_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y - vpr.y/2)
	var top_right = Vector2(player.global_position.x + vpr.x/2, player.global_position.y - vpr.y/2)
	var bottom_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y + vpr.y/2)
	var bottom_right = Vector2(player.global_position.x + vpr.x/2, player.global_position.y + vpr.y/2)
	var pos_side = ["up","down","right","left"].pick_random()
	var spawn_pos1 = Vector2.ZERO
	var spawn_pos2 = Vector2.ZERO
	
	match pos_side:
		"up":
			spawn_pos1 = top_left
			spawn_pos2 = top_right
		"down":
			spawn_pos1 = bottom_left
			spawn_pos2 = bottom_right
		"right":
			spawn_pos1 = top_right
			spawn_pos2 = bottom_right
		"left":
			spawn_pos1 = top_left
			spawn_pos2 = bottom_left
	
	var x_spawn = randf_range(spawn_pos1.x, spawn_pos2.x)
	var y_spawn = randf_range(spawn_pos1.y,spawn_pos2.y)
	return Vector2(x_spawn,y_spawn)

# NOTE: FIX!
func despawn_enemies():
	for enemy in get_children():
		if enemy.is_in_group("enemy"):
			enemy.queue_free()
			#enemy_counter -= 1
	#counter = 0
	basic_enemy_counter = 0
	ranged_enemy_counter = 0

func pause_spawning():
	timer.stop()

func start_spawning():
	timer.start()
	timer_2.start()
	
func start_spawn_minions():
	timer.start()

func on_enemy_death():
	basic_enemy_counter -= 1
	#print("hi", enemy_counter)

func player_level_up():
	leveled_up = true
	
func scaling(body):
	if leveled_up == true:
		if body == null:
			pass
		else:
			if body.is_in_group("slime"):
				body.hp += 0.1225*body.hp
				body.damage += 0.1*body.damage
			
			elif body.is_in_group("skeleton"):
				body.maxHealth += 0.15*body.maxHealth
				body.damage += 0.05*body.damage
