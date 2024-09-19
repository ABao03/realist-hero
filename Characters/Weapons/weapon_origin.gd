extends Marker2D

var player

@onready var bullet = preload("res://Characters/Weapons/player_bullet.tscn")

# Dictionary to keep track of timers and their identifiers
var timers = {}

# Track orbiting weapon instances
var bulwarkCount = 0
var gauntletsCount = 0
var oniCount = 0

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	for thisPlayer in players:
		if thisPlayer != null:
			player = thisPlayer
			
	if player != null:
		position = player.global_position
	
	# Example: Create multiple timers with different wait times
	#create_timer(2.0, "timer_1")
	#create_timer(4.0, "timer_2")
	#create_timer(1.0, "timer_3")

# Function to dynamically create a Timer node
func create_timer(wait_time: float, timer_id: String) -> void:
	# Create a new Timer node
	var timer = Timer.new()
	# Set the timer's wait time
	timer.wait_time = wait_time
	# Add the Timer as a child of the current node
	add_child(timer)
	# Store the timer in the dictionary with its identifier
	timers[timer_id] = timer
	# Connect the Timer's timeout signal to a lambda function that calls _on_timer_timeout with the timer_id
	timer.timeout.connect(func() -> void:
		_on_timer_timeout(timer_id)
	)
	# Start the Timer
	timer.start()

# Function to dynamically remove a timer node
func remove_timer(timer_id: String) -> void:
	if timers.has(timer_id):
		timers[timer_id].queue_free()
		timers.erase(timer_id)

# Function called when the Timer times out
func _on_timer_timeout(timer_id: String) -> void:
	# Perform any action based on the specific timer
	var thisBullet = bullet.instantiate()

	match timer_id:
		"Pickaxe":
			get_parent().add_child(thisBullet)
			thisBullet.setup("1", true)
			
		"Dagger":
			get_parent().add_child(thisBullet)
			thisBullet.setup("2", true)
			thisBullet.scale.x = 0.75
			thisBullet.scale.y = 0.75
			
		"Wand":
			get_parent().add_child(thisBullet)
			thisBullet.setup("3", false)
			thisBullet.scale.x = 1.5
			thisBullet.scale.y = 1.5
			for i in range(thisBullet.bulletCount):
				if i != 0:
					thisBullet = bullet.instantiate()
					get_parent().add_child(thisBullet)
					thisBullet.setup("3", false)
				thisBullet.add_even_spread(i)
			
		"Longsword":
			get_parent().add_child(thisBullet)
			thisBullet.setup("4", false)
			thisBullet.scale.x = 1.5
			thisBullet.scale.y = 1.5
			
		"Bulwark":
			get_parent().add_child(thisBullet)
			thisBullet.setup("5", false)
			thisBullet.orbitRadius = 40
			bulwarkCount += 1
			thisBullet.check_bulwark_count(bulwarkCount)
			
		"Sickle":
			get_parent().add_child(thisBullet)
			thisBullet.setup("6", true)
			
		"Suspicious Seal":
			get_parent().add_child(thisBullet)
			thisBullet.setup("7", true)
			thisBullet.scale.x = 0.75
			thisBullet.scale.y = 0.75
			thisBullet.add_random_spread()
			
		"Inverted Spear":
			get_parent().add_child(thisBullet)
			thisBullet.setup("12",false)
		
		"Oni's Star":
			get_parent().add_child(thisBullet)
			thisBullet.setup("10",true)
			thisBullet.orbitRadius = 50
			oniCount += 1
			thisBullet.check_oni_count(oniCount)
			
		
		#"Gauntlets":
			#get_parent().add_child(thisBullet)
			#thisBullet.setup("5", false)
			#thisBullet.orbitRadius = 60
			#gauntletCount += 1
			#thisBullet.check_gauntlet_count(gauntletCount)

func _process(delta):
	position = player.position

func bulwark_deleted():
	bulwarkCount -= 1

func gauntlets_deleted():
	gauntletsCount -= 1

func oni_deleted():
	oniCount -= 1

# old
#func _on_timer_timeout():
	#weapon.shoot()
