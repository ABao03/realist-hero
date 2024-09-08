extends Marker2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func display_number(damage: int, position: Vector2):
	var number = Label.new()
	number.global_position = position
	number.text = str(damage)
	number.z_index = 5
	number.label_settings = LabelSettings.new()
	
	var color = "#FFF"
	if damage == 0:
		color = Color(0, 0, 1, 0)
	
	number.label_settings.font_color = color
	
	number.label_settings.font_size = 20
	
	if damage != 0:
		number.label_settings.outline_color = "#000"
	
	if damage > 0:
		number.label_settings.outline_size = 4
		
	call_deferred("add_child", number)
	
	await number.resized
	#await magic_number.resized
	number.pivot_offset = Vector2(number.size / 2)
	
	var tween = get_tree().create_tween()
	var magic_tween = get_tree().create_tween()
	
	tween.set_parallel(true)
	magic_tween.set_parallel(true)
	
	tween.tween_property(
		number, "position:y", number.position.y - 24, 0.25
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		number, "position:y", number.position.y, 0.5
	).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(
		number, "scale", Vector2.ZERO, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	await tween.finished
	#await magic_tween.finished
	number.queue_free()


