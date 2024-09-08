extends Marker2D

var player

@onready var bullet = preload("res://Characters/Weapons/player_bullet.tscn")

# Dictionary to keep track of timers and their identifiers
var timers = {}

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
	var imageFilePath
	var thisBullet = bullet.instantiate()
	var thisItem
	match timer_id:
		"Pickaxe":
			imageFilePath = "res://Assets/" + timer_id.to_lower().replace(" ", "_") + "_weapon.png"
			thisItem = DataHandler.item_data["1"]
			
			get_parent().add_child(thisBullet)
			thisBullet.setup(imageFilePath, thisItem["Damage"])
		"Dagger":
			imageFilePath = "res://Assets/" + timer_id.to_lower().replace(" ", "_") + "_weapon.png"
			thisItem = DataHandler.item_data["2"]
			
			get_parent().add_child(thisBullet)
			thisBullet.setup(imageFilePath, thisItem["Damage"])
			thisBullet.scale.x = 0.75
			thisBullet.scale.y = 0.75
		"timer_3":
			print("Do something specific for timer 3")

func _process(delta):
	position = player.position

# old
#func _on_timer_timeout():
	#weapon.shoot()
