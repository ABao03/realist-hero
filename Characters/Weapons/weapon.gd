extends Marker2D
@onready var player = get_tree().get_first_node_in_group("player")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	look_at(get_global_mouse_position())
	# Calculate the direction vector pointing from the follower to the player
	var direction = (player.global_position - global_position)
	# Move the follower towards the player
	global_position += direction * player.speed * delta
