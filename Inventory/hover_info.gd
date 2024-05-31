extends ColorRect

@onready var hoverGrid = $GridContainer
var nameInfo = Label.new()
var statInfo = Label.new()

func _process(_delta):
	global_position = get_global_mouse_position()

func _ready():
	visible = false

func create_info(selectedItem):
	z_index = 5
	
	nameInfo.label_settings = LabelSettings.new()
	nameInfo.text = selectedItem.item_name
	nameInfo.label_settings.font_size = 11
	nameInfo.z_index = 6
	hoverGrid.add_child(nameInfo)
	
	statInfo.label_settings = LabelSettings.new()
	statInfo.label_settings.font_size = 9
	statInfo.z_index = 6
	
	for stat in selectedItem.stats_data:
		statInfo.text += stat + ": " + str(selectedItem.stats_data[stat]) + "\n"
	hoverGrid.add_child(statInfo)

func mouse_entered(selectedItem):
	create_info(selectedItem)
	visible = true

func mouse_exited():
	nameInfo.text = ""
	statInfo.text = ""
	visible = false

func counter_rotate():
	rotation = deg_to_rad(-rotation_degrees)
