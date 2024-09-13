extends GPUParticles2D

@onready var timeCreated = Time.get_ticks_msec()

func _process(_delta):
	if Time.get_ticks_msec() - timeCreated > 800:
		queue_free()
