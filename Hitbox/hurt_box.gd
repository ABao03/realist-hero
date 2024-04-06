extends Area2D

@export var HurtBoxType = 0
# @export_enum("Cooldown", "HitOnce", "DisableHitBox") var HurtBoxType = 0

@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableTimer

signal hurt(damage)


func _on_area_entered(area):
	if area.is_in_group("attack"):
		if not area.get("damage") == null:
			match HurtBoxType:
				0: # disable collision check if just hit (meaning that the collision is still on cooldown)
					collision.call_deferred("set", "disabled", true)
					disableTimer.start()
				1: # hit once (???)
					pass
				2: # enable damage cooldown if recently hit 
					if area.has_method("tempdisable"):
						area.tempdisable()
			var damage = area.damage
			emit_signal("hurt", damage)

# once cooldown runs out, re-enable hitbox
func _on_disable_timer_timeout():
	collision.call_deferred("set", "disabled", false)
