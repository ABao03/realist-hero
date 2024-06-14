extends TextureButton

@export var abilityType = ""
@export var cooldownTime = 1
var onCooldown = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.visible = false
	$Timer.wait_time = cooldownTime
	$TextureProgressBar.value = 0
	$TextureProgressBar.texture_progress = texture_normal
	set_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Label.text = "%0.1f" % $Timer.time_left
	$TextureProgressBar.value = ($Timer.time_left/cooldownTime) * 100


func _on_timer_timeout():
	$Label.visible = false
	$TextureProgressBar.value = 0
	onCooldown = false
	set_process(false)


func activated():
	if onCooldown == false:
		onCooldown = true
		$Label.visible = true
		$Timer.start()
		set_process(true)
		pass # Replace with function body.
