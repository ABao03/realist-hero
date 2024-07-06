extends Node2D
@onready var lightning = $Lightning
@onready var lightningSlash = $LightningSlash
@onready var fireball = $Fireball
@onready var girlCanvas = $GirlCanvas
@onready var girlTextbox = $GirlCanvas/TextBox

# Called when the node enters the scene tree for the first time.
func _ready():
	girlCanvas.visible = false

func _exit_tree():
	remove_from_group("ability")

func ability_used(pos, magicDamage):
	#Dialogic.start("girl_test")
	#lightning.hitbox.magicDamage = int(magicDamage) + 10
	#lightning.play_animation(pos)
	fireball.hitbox.magicDamage = int(magicDamage) + 10
	fireball.play_animation(pos)

func ult_used(pos, magicDamage):
	lightningSlash.hitbox.magicDamage = int(magicDamage) * 5 + 8
	lightningSlash.play_animation(pos)

func start_girl_dialogue():
	girlCanvas.visible = true
	girlTextbox.visible = true
