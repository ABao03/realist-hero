extends Area2D

@export var damage = 1
@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableHitboxTimer

func tempdisable():
	# Initialize damage cooldown after being hit. 
	collision.call_deferred("set", "disabled", true)
	disableTimer.start()


# Re-enable collisions after cooldown runs out. 
func _on_disable_hitbox_timer_timeout():
	collision.call_deferred("set", "disabled", false)
