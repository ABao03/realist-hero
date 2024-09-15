extends ColorRect

@onready var lblName = $lbl_name
@onready var lblDescription = $lbl_description
@onready var itemIcon = $ColorRect/ItemIcon

var mouse_over = false
var item = null
@onready var player = get_tree().get_first_node_in_group("player")

signal selected_upgrade(upgrade)

func _ready():
	connect("selected_upgrade",Callable(player,"upgrade_character"))
	#if item == null:
		#item = "food"
	lblName.text = item["Name"]
	lblDescription.text = item["Info"]
	var file_name = DataHandler.item_data[str(item["ID"])]["Name"]
	file_name = file_name.replace("'", "")
	file_name = file_name.replace(" ", "_")
	file_name = file_name.to_lower()
	var Icon_path = "res://Assets/Images/Weapons/" + file_name + ".png"
	itemIcon.texture = ResourceLoader.load(Icon_path)
	
func _input(event):
	if event.is_action("mouse_leftclick"):
		if mouse_over:
			emit_signal("selected_upgrade",item)

func _on_mouse_entered():
	mouse_over = true

func _on_mouse_exited():
	mouse_over = false
