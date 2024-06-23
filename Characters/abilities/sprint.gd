extends Node2D

@onready var players = get_tree().get_nodes_in_group("player")
var player
@onready var hurtbox = get_node("../HurtBox")
@onready var originalSpeed
@onready var sprintSpeed = 2000
@onready var buttonclicked: bool = false
var isReady : bool = true
var isPressed : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	for thisPlayer in players:
		if thisPlayer != null:
			player = thisPlayer
	originalSpeed = player.speed

func _input(event: InputEvent): # Show/hide pause menu
	if event.is_action_pressed("shift") and isReady == true:
		$Timer.start()
		$CooldownTimer.start()
		player.speed = sprintSpeed
		isReady = false
		hurtbox.collision.call_deferred("set", "disabled", true)
		#player.collision.call_deferred("set", "disabled", true)
		player.set_collision_mask_value(2, false)	
	else:
		pass

func _on_sprint_button_pressed():
	if isReady == true:
		$Timer.start()
		$CooldownTimer.start()
		player.speed = sprintSpeed
		isReady = false
		hurtbox.collision.call_deferred("set", "disabled", true)
		#player.collision.call_deferred("set", "disabled", true)
		player.set_collision_mask_value(2, false)
		
	else:
		pass
	
func _on_timer_timeout():
	player.speed = originalSpeed
	hurtbox.collision.call_deferred("set", "disabled", false)
	#player.collision.call_deferred("set", "disabled", false)
	player.set_collision_mask_value(2, true)

func _on_cooldown_timer_timeout():
	isReady = true
	
## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

