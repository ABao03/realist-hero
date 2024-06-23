extends Node2D
@onready var players = get_tree().get_nodes_in_group("player")
var player
@onready var currentHealth
@onready var maxHealth
@onready var healAmount = 20
var isReady : bool = true
@onready var healthBar = get_node('%HealthBar')

func _ready():
	for thisPlayer in players:
		if thisPlayer != null:
			player = thisPlayer

func _on_heal_button_pressed():
	if isReady == true:
		currentHealth = player.hp
		maxHealth = player.maxhp
		
		if currentHealth < maxHealth and (currentHealth + healAmount) < maxHealth:
			$HealTimer.start()
			player.hp = player.hp + healAmount
			isReady = false
			set_healthbar(player.hp, maxHealth)
			
		elif currentHealth < maxHealth and (currentHealth + healAmount) > maxHealth:
			$HealTimer.start()
			player.hp = maxHealth
			isReady = false
			set_healthbar(player.hp, maxHealth)
	else:
		pass # Replace with function body.

func set_healthbar(set_value = 1, set_max_value = 100):
	healthBar.value = set_value
	healthBar.max_value = set_max_value

func _on_heal_timer_timeout():
	isReady = true
