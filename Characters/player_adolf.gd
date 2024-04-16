# https://www.youtube.com/watch?v=Xf2RduncoNU

extends CharacterBody2D

# Stats
var speed : float = 100
var hp = 100

# Attacks
var iceSpear = preload("res://Characters/Weapons/weapon.tscn") # This has to change if u change the filename

# AttackNodes
@onready var iceSpearTimer = get_node("%IceSpearTimer")
@onready var iceSpearAttackTimer = get_node("%IceSpearAttackTimer")

# IceSpear (change later)
var icespear_ammo = 0
var icespear_baseammo = 1
var icespear_attackspeed = 1.5
var icespear_level = 1

# Enemy Related
var enemy_close = []

# Animation Status
var isAttacking: bool = false

@export var starting : Vector2 = Vector2(0, 1)
@onready var animation = $AnimationPlayer/AnimationTree
@onready var sprite = $Sprite2D
@onready var state_machine = animation.get('parameters/playback')

func _ready():
	attack()
	update_animation(starting)

func handleInput():
	if Input.is_action_just_pressed("mouse_leftclick"):
		isAttacking = true

func _physics_process(_delta):
	var input_direction = Vector2(
		Input.get_action_strength('right') - Input.get_action_strength('left'),
		Input.get_action_strength('down') - Input.get_action_strength('up')
	)
	
	velocity = velocity.normalized()
	velocity = input_direction * speed
		
	move_and_slide()
	new_state()
	
	handleInput()
	update_animation(input_direction)
	
func update_animation(move_input: Vector2):
	if move_input == Vector2.ZERO:
		animation["parameters/conditions/idle"] = true
		animation["parameters/conditions/walk"] = false
		
	else:
		animation["parameters/conditions/idle"] = false
		animation["parameters/conditions/walk"] = true
		
		animation["parameters/Idle/blend_position"] = move_input
		animation["parameters/Walk/blend_position"] = move_input
	
	if isAttacking == true:
		animation["parameters/conditions/attack"] = true
		isAttacking = false
		
	else:
		animation["parameters/conditions/attack"] = false

func attack():
	if icespear_level > 0:
		iceSpearTimer.wait_time = icespear_attackspeed
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()
		
func new_state():
	if velocity != Vector2.ZERO:
		state_machine.travel('Walk')
	else:
		state_machine.travel('Idle')


func _on_hurt_box_hurt(damage):
	hp -= damage
	if hp == 0:
		get_tree().change_scene_to_file("res://Menu/death.tscn")
	print(hp)


func _on_ice_spear_timer_timeout():
	pass # Replace with function body.


func _on_ice_spear_attack_timer_timeout():
	pass
