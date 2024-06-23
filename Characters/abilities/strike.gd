extends Node2D

@onready var players = get_tree().get_nodes_in_group("player")
var player
@onready var originalDamage
@onready var newDamage
@onready var boost_ready : bool = true
@onready var button_pressed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	for thisPlayer in players:
		if thisPlayer != null:
			player = thisPlayer
	await player.ready
	originalDamage = player.attackBox1.damage


	newDamage = originalDamage*1.5

func _on_button_pressed():
	if boost_ready == true:
		#$Timer.start()
		#boost_ready = false
		player.attackBox1.damage = newDamage
		player.attackBox2.damage = newDamage
		button_pressed = true

func _input(event: InputEvent): # Show/hide pause menu
	if event.is_action_pressed("mouse_leftclick") and boost_ready == true and button_pressed == true:
		#print(player.attackBox1.damage)
		$Timer.start()
		boost_ready = false
		button_pressed = false


func _on_timer_timeout():
	player.attackBox1.damage = originalDamage
	player.attackBox2.damage = originalDamage
	$CoolDown.start()
	
func _on_cool_down_timeout():
	boost_ready = true
	#print("ready")
	


#
#func _on_timer_timeout():
	#player.attackBox1.damage = originalDamage
	#$CoolDown.start()
	#print("timer time out") # Replace with function body.
#
##for slow put a collision shape around the player in the skill button -> when its active let it be doing stuff
#
#




