extends Node2D

# Hold array of currently alive enemies 
@export var spawns: Array[Spawn_info] = []

# Call player node from scene
@onready var players = get_tree().get_nodes_in_group("player")
@onready var enemy = preload("res://Characters/Enemy/ranged_boss.tscn")

#Get enemy nodes
#@onready var slime = get_tree().get_first_node_in_group("slime")
@onready var skeleton = get_tree().get_first_node_in_group("skeleton")

@onready var player

# Delay between spawns (I think)
@export var time = 0
@onready var timer = $Timer
@onready var timer_2 = $Dragon_Timer

@onready var enemy_cap

@onready var dragon_spawned: bool = false

#keeps track of number of enemies
@onready var enemy_counter = 0
#signal changetime(time)

#Keeps track of scaling
@onready var leveled_up: bool = false

func _ready():
	#connect("changetime",Callable(player,"change_time"))
	for thisPlayer in players:
		if thisPlayer != null:
			player = thisPlayer

# When timer hits 0, run this code
func _on_timer_timeout():
	var player_level = player.experience_level
	#enemy_cap = 7 + player_level*2 #max number of enemies per level
	if player_level == 1:
		enemy_cap = 7
	elif player_level == 2:
		enemy_cap = 14
	elif player_level == 3:
		enemy_cap = 20
	elif player_level == 4:
		enemy_cap = 30
		
	time += 1
	var enemy_spawns = spawns
	
	if player.experience_level == 5 and get_tree().current_scene.name != "Tutorial_World" and dragon_spawned == false:
		dragon_spawned = true
		dragon_spawn()
	
	# Basically, every time the timer hits zero, load the enemy 
	for i in enemy_spawns:
		#print("bro ", enemy_counter)
		#print("habibi ", enemy_cap)
		if enemy_counter < enemy_cap:  #when the number of enemies is smaller than the enemy cap
			if time >= i.time_start and time <= i.time_end:
				if i.spawn_delay_counter < i.enemy_spawn_delay:
					i.spawn_delay_counter += 1
				else:
					i.spawn_delay_counter = 0
					var new_enemy = i.enemy
					var counter = 0
					while counter < i.enemy_num:
						var enemy_spawn = new_enemy.instantiate()
						enemy_spawn.global_position = get_random_position()
						add_child(enemy_spawn)
						
						var slime = get_tree().get_first_node_in_group("slime")
						#print(slime)
						scaling(slime)
						
						var skeleton = get_tree().get_first_node_in_group("skeleton")
						scaling(skeleton)

						counter += 1
						enemy_counter += 1 #number of events gets incremeneted
		elif enemy_counter >= enemy_cap:
			pass
	#emit_signal("changetime",time)

func dragon_spawn():
	timer.stop()
	for bruh in get_children():
		if bruh.is_in_group("enemy"):
			bruh.queue_free()
			#print(player.experience_level)
	var enemy_instance = enemy.instantiate()
	enemy_instance.global_position =Vector2(-450,-212)
	add_child(enemy_instance)

#func _on_dragon_timer_timeout():
	#if player.experience_level == 2 && get_tree().current_scene.name != "Tutorial_World":
		#timer.stop()
		#for bruh in get_children():
			#if bruh.is_in_group("enemy"):
				#bruh.queue_free()
			#print(player.experience_level)
		#var enemy_instance = enemy.instantiate()
		#enemy_instance.global_position =Vector2(10,200)
		#add_child(enemy_instance)
			

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

func despawn_enemies():
	for enemy in get_children():
		if enemy.is_in_group("enemy"):
			enemy.queue_free()
			enemy_counter -= 1
	#counter = 0

func pause_spawning():
	timer.stop()

func start_spawning():
	timer.start()
	timer_2.start()
	
func start_spawn_minions():
	timer.start()

func on_enemy_death():
	enemy_counter = enemy_counter - 1
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
			
		
			#body.hp = body.hp + (player.experience_level-1)*body.hp*0.1225

