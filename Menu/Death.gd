extends Control
var deathInventory

#GUI
@onready var itemIcon = $ItemIcon
@onready var scoreLabel = $ScoreLabel
var score : int
@onready var itemTimer = $ItemTimer
@onready var button = $Button

func tallyInventory():
	for item in deathInventory:
		var file_name = DataHandler.item_data[str(item.item_ID)]["Name"]
		file_name = file_name.replace("'", "")
		file_name = file_name.replace(" ", "_")
		file_name = file_name.to_lower()
		var Icon_path = "res://Assets/" + file_name + ".png"
		itemIcon.texture = ResourceLoader.load(Icon_path)
		pop_effect()
		var itemScore = item.item_score
		score += int(itemScore)
		scoreLabel.text = str(score)
		await get_tree().create_timer(1).timeout
	
	button.visible = true

func _on_button_pressed():
	get_tree().change_scene_to_file("res://Worlds/Hub World/hubworld.tscn")

func pop_effect():
	## Reset scale to ensure it starts from the base scale
	#itemIcon.scale = Vector2(1, 1)
	#var tween = get_tree().create_tween()
	## Scale up
	#tween.tween_property(itemIcon, "scale", itemIcon.scale, Vector2(1.2, 1.2), 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	## Scale back down
	#tween.tween_property(itemIcon, "scale", Vector2(1.2, 1.2), Vector2(1, 1), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.1)  # Delay start by 0.1s
	## Start the tween
	#tween.start()
	pass
