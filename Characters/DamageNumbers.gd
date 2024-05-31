extends Marker2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func display_number(damage: int, position: Vector2, magicDamage: int, is_critical: bool = false):
	var number = Label.new()
	number.global_position = position
	number.text = str(damage)
	number.z_index = 5
	number.label_settings = LabelSettings.new()
	
	var magic_number = Label.new()
	magic_number.global_position = number.global_position + Vector2(20, 10)
	magic_number.text = str(magicDamage)
	magic_number.z_index = 5
	magic_number.label_settings = LabelSettings.new()
	
	var color = "#FFF"
	var magicColor = "#5e03fc"
	if is_critical:
		color = "#B22"
	if magicDamage == 0:
		magicColor = Color(0, 0, 1, 0)
	if damage == 0:
		color = Color(0, 0, 1, 0)
	
	number.label_settings.font_color = color
	magic_number.label_settings.font_color = magicColor
	
	number.label_settings.font_size = 18
	magic_number.label_settings.font_size = 18
	
	if damage != 0:
		number.label_settings.outline_color = "#000"
	if magicDamage != 0:
		magic_number.label_settings.outline_color = "#000"
	
	number.label_settings.outline_size = 1
	magic_number.label_settings.outline_size = 1
		
	call_deferred("add_child", magic_number)
	call_deferred("add_child", number)
	
	await number.resized
	#await magic_number.resized
	number.pivot_offset = Vector2(number.size / 2)
	magic_number.pivot_offset = Vector2(number.size / 2)
	
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
	
	magic_tween.tween_property(
		magic_number, "position:y", magic_number.position.y - 24, 0.25
	).set_ease(Tween.EASE_OUT)
	magic_tween.tween_property(
		magic_number, "position:y", magic_number.position.y, 0.5
	).set_ease(Tween.EASE_IN).set_delay(0.25)
	magic_tween.tween_property(
		magic_number, "scale", Vector2.ZERO, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	await tween.finished
	#await magic_tween.finished
	number.queue_free()
	magic_number.queue_free()


