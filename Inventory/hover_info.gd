extends ColorRect

@onready var hoverGrid = $GridContainer
var nameInfo = Label.new()
var statInfo = Label.new()

func _process(_delta):
	global_position = get_global_mouse_position()

func _ready():
	visible = false
	
	nameInfo.label_settings = LabelSettings.new()
	nameInfo.label_settings.font_size = 11
	nameInfo.z_index = 6
	hoverGrid.add_child(nameInfo)
	
	statInfo.label_settings = LabelSettings.new()
	statInfo.z_index = 6
	statInfo.label_settings.font_size = 9
	hoverGrid.add_child(statInfo)

func create_info(selectedItem):
	z_index = 5
	nameInfo.text = selectedItem.item_name
	
	for stat in selectedItem.stats_data:
		statInfo.text += stat + ": " + str(selectedItem.stats_data[stat]) + "\n"

func mouse_entered(selectedItem):
	create_info(selectedItem)
	visible = true

func mouse_exited():
	nameInfo.text = ""
	statInfo.text = ""
	visible = false

func counter_rotate():
	rotation = deg_to_rad(-rotation_degrees)
