# This code is responsible for DEALING damage to another entity.
# It is a generic script with a modifiable damage value.

extends Area2D

# Modifiable damage value. Shows up in Inspector tab (right-hand side).
@export var damage = 1
@export var magic = false
@export var crit = 0.0
@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableHitboxTimer

func tempdisable():
	# Initialize damage cooldown after being hit. 
	collision.call_deferred("set", "disabled", true)
	disableTimer.start()


# Re-enable collisions after cooldown runs out. 
func _on_disable_hitbox_timer_timeout():
	collision.call_deferred("set", "disabled", false)
