extends Marker2D
@onready var player = get_tree().get_first_node_in_group("player")

# Animation Status
var isAttacking: bool = false

@onready var animation = $Area2D/AnimationPlayer/AnimationTree
@onready var state_machine = animation.get('parameters/playback')

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func handleInput():
	if Input.is_action_just_pressed("mouse_leftclick"):
		isAttacking = true

func new_state():
	if isAttacking == true:
		animation["parameters/conditions/attack"] = true
		animation["parameters/conditions/reset"] = false
		isAttacking = false
	else:
		animation["parameters/conditions/attack"] = false
		animation["parameters/conditions/reset"] = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	look_at(get_global_mouse_position())
	# Calculate the direction vector pointing from the follower to the player
	var direction = (player.global_position - global_position)
	# Move the follower towards the player
	global_position += direction * player.speed * delta
	
	new_state()
	handleInput()
