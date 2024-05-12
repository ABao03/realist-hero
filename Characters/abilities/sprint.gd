extends Node2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var hurtbox = get_node("../HurtBox")
@onready var originalSpeed
@onready var sprintSpeed = 2000
var isReady : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
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
	print("sprint ready")
	
## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

