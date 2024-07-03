extends Node2D

# Hold array of currently alive enemies 
@export var spawns: Array[Spawn_info] = []

# Call player node from scene
@onready var players = get_tree().get_nodes_in_group("player")
@onready var enemy = preload("res://Characters/Enemy/ranged_boss.tscn")

var player

# Delay between spawns (I think)
@export var time = 0
@onready var timer = $Timer
@onready var timer_2 = $Dragon_Timer

@onready var dragon_spawned: bool = false

#signal changetime(time)

func _ready():
	#connect("changetime",Callable(player,"change_time"))
	for thisPlayer in players:
		if thisPlayer != null:
			player = thisPlayer

# When timer hits 0, run this code
func _on_timer_timeout():
	time += 1
	var enemy_spawns = spawns
	
	if player.experience_level == 2 and get_tree().current_scene.name != "Tutorial_World" and dragon_spawned == false:
		dragon_spawned = true
		dragon_spawn()
	
	# Basically, every time the timer hits zero, load the enemy 
	for i in enemy_spawns:
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
					counter += 1
	#emit_signal("changetime",time)

func dragon_spawn():
	timer.stop()
	for bruh in get_children():
		if bruh.is_in_group("enemy"):
			bruh.queue_free()
			#print(player.experience_level)
	var enemy_instance = enemy.instantiate()
	enemy_instance.global_position =Vector2(10,200)
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

func pause_spawning():
	timer.stop()

func start_spawning():
	timer.start()
	timer_2.start()
	
func start_spawn_minions():
	timer.start()

