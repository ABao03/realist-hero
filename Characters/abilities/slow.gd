extends Node2D

@onready var slow = get_node("%Slow")
@onready var player = get_tree().get_first_node_in_group("player")
@onready var player_hp
@onready var original_speed
@onready var new_speed


func _on_button_pressed():
	pass

func _process(delta):
	pass
	#if player_hp*2 <= original_hp:
		#$Slow/Slow.disabled = false
	#else:
		#pass


func _on_slow_body_entered(body):
	
	original_speed = body.movement_speed
	new_speed = original_speed/2

	body.movement_speed = new_speed
	print("slow active")
	$Timer.start()
	

func _on_slow_body_exited(body):
	body.movement_speed = original_speed

func _on_timer_timeout():
	$Slow/Slow.disabled = true
