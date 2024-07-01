extends Sprite2D

func _ready():
	ghosting()

func set_property(tx_pos, tx_scale, tx_rotation):
	position = tx_pos
	scale = tx_scale
	rotation = tx_rotation - PI

func ghosting():
	var tween_fade = get_tree().create_tween()
	tween_fade.tween_property(self, "self_modulate",Color(1,1,1,0), 0.25)
	await tween_fade.finished
	queue_free()
