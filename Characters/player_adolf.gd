extends CharacterBody2D

@export var speed : float = 100
@export var starting : Vector2 = Vector2(0, 1)
@onready var animation = $AnimationPlayer/AnimationTree
@onready var state_machine = animation.get('parameters/playback')
func _ready():
	update_animation(starting)

func _physics_process(_delta):
	var input_direction = Vector2(
		Input.get_action_strength('right') - Input.get_action_strength('left'),
		Input.get_action_strength('down') - Input.get_action_strength('up')
	)
	update_animation(input_direction)
	velocity = input_direction * speed
	move_and_slide()
	new_state()
func update_animation(move_input: Vector2):
	if move_input != Vector2.ZERO:
		animation.set('parameters/Walk/blend_position', move_input)
		animation.set("parameters/Walk/blend_position", move_input)
func new_state():
	if velocity != Vector2.ZERO:
		state_machine.travel('Walk')
	else:
		state_machine.travel('Idle')
