# This code is responsible for RECEIVING damage from another entity. 
# AKA HP goes down. 

# _on_hurt_box_hurt() detects when a hitbox enters the hurtbox. It then applies the 
# hitbox's damage value to the entity. 

extends Area2D

@export var HurtBoxType = 0 
# @export_enum("Cooldown", "HitOnce", "DisableHitBox") var HurtBoxType = 0 

@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableTimer 

# Send the signal for damage taken
signal hurt(damage)

# Detect when the hitbox enters a hurtbox 
func _on_area_entered(area): 
	# Check if the hitbox belongs to the attack group (inside of node) 
	if area.is_in_group("attack"):
		if not area.get("damage") == null:
			match HurtBoxType:
				0: # Disable collision check if just hit (meaning that the collision is still on cooldown) 
					collision.call_deferred("set", "disabled", true)
					disableTimer.start()
				1: # Hit once (???)
					pass
				2: # Enable damage cooldown if recently hit 
					if area.has_method("tempdisable"):
						area.tempdisable()
			var damage = area.damage
			emit_signal("hurt", damage)

# Once cooldown runs out, re-enable hurtbox
func _on_disable_timer_timeout():
	collision.call_deferred("set", "disabled", false)
