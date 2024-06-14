extends Node2D
@onready var lightning = $Lightning
@onready var lightningSlash = $LightningSlash

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func ability_used(pos, magicDamage):
	lightning.hitbox.magicDamage = int(magicDamage) + 10
	lightning.play_animation(pos)

func ult_used(pos, magicDamage):
	lightningSlash.hitbox.magicDamage = int(magicDamage) * 5 + 8
	lightningSlash.play_animation(pos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
