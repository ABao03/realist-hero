extends CharacterBody2D

@export var movement_speed = 0.0
@export var hp = 0.0
@export var experience = 0

@onready var snd = $Snd

@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var sprite = $Sprite2D
@onready var damage_numbers_origin = $DamageNumbers

func _on_hurt_box_hurt(damage, isMagic, isCrit):
	if isCrit == true:
		damage = damage * 2
	DamageNumbers.display_number(damage, damage_numbers_origin.global_position)
	
	if isMagic == 0 && isCrit == false:
		snd.stream = load("res://Assets/SoundEffects/hit.wav")
		snd.play()
	if isCrit == true:
		snd.stream = load("res://Assets/SoundEffects/crit_hit.mp3")
		snd.play()

