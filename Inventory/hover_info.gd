extends ColorRect

@onready var hoverGrid = $GridContainer
var nameInfo = Label.new()
var statInfo = Label.new()

func _process(_delta):
	global_position = get_global_mouse_position()

func _ready():
	visible = false
	
	nameInfo.label_settings = LabelSettings.new()
	nameInfo.label_settings.font_size = 20
	nameInfo.z_index = 6
	hoverGrid.add_child(nameInfo)
	
	statInfo.label_settings = LabelSettings.new()
	statInfo.z_index = 6
	statInfo.label_settings.font_size = 16
	hoverGrid.add_child(statInfo)

func create_info(selectedItem):
	z_index = 5
	nameInfo.text = selectedItem.item_name
	
	# old code for stats_data
	#for stat in selectedItem.stats_data:
		#statInfo.text += stat + ": " + str(selectedItem.stats_data[stat]) + "\n"
	statInfo.text += "Damage: " + str(selectedItem.item_damage) + "\n"
	statInfo.text += "Type: " + str(selectedItem.item_bullet_type) + "\n"
	statInfo.text += "Class: " + str(selectedItem.item_class) + "\n"
	statInfo.text += "Bullet Count: " + str(selectedItem.item_bullet_count) + "\n"
	
	var fire_rate_string
	if (selectedItem.item_fire_rate < 1):
		fire_rate_string = "Fast"
	elif (1 <= selectedItem.item_fire_rate and selectedItem.item_fire_rate < 2):
		fire_rate_string = "Medium"
	else:
		fire_rate_string = "Slow"
	statInfo.text += "Fire Rate:" + fire_rate_string + "\n"
	
	statInfo.text += "Bullet Piercing: " + str(selectedItem.item_piercing) + "\n"
	statInfo.text += "Bullet Speed: " + str(selectedItem.item_speed) + "\n"

func mouse_entered(selectedItem):
	create_info(selectedItem)
	visible = true

func mouse_exited():
	nameInfo.text = ""
	statInfo.text = ""
	visible = false

func counter_rotate():
	rotation = deg_to_rad(-rotation_degrees)
