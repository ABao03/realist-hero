extends Node2D

@onready var IconRect_path = $Icon
@onready var whiteIcon = $WhiteIcon
@onready var animation = $AnimationPlayer

var item_ID : String
var item_name : String
var item_grids := []
var stats_data := {}
var item_info : String
var selected = false
var grid_anchor = null

# Hover Info
@onready var hoverInfo = get_tree().get_first_node_in_group("info")
signal entered_item(selectedItem)
signal exited_item()
signal item_rotated()

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	connect("entered_item",Callable(hoverInfo,"mouse_entered"))
	connect("exited_item",Callable(hoverInfo,"mouse_exited"))
	connect("item_rotated",Callable(hoverInfo,"counter_rotate"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
# Makes the picked up item follow the cursor. 
func _process(delta):
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)

# Load the image in the assets as an item
func load_item(a_ItemID : int) -> void:
	# NOTE: .PNG FILE MUST HAVE THE EXACT SAME FILE NAME AS THE ITEM NAME OR THIS LINE WILL NOT WORK
	var file_name = DataHandler.item_data[str(a_ItemID)]["Name"]
	file_name = file_name.replace("'", "")
	file_name = file_name.replace(" ", "_")
	file_name = file_name.to_lower()
	var Icon_path = "res://Assets/" + file_name + ".png"
	IconRect_path.texture = ResourceLoader.load(Icon_path)
	whiteIcon.texture = ResourceLoader.load(Icon_path)
	
	# Generate the grid for the image
	for grid in DataHandler.item_grid_data[str(a_ItemID)]:
		var converter_array := []
		for i in grid:
			converter_array.push_back(int(i))
		item_grids.push_back(converter_array)
	
	# Andrew wuz here
	# Extra functionality to load in all the data for an item
	for stat in DataHandler.item_data[str(a_ItemID)]:
		var thisValue = DataHandler.item_data[str(a_ItemID)][stat]
		var intValue = float(thisValue)

		if str("%.2f" % intValue) == str(thisValue) || str("%.3f" % intValue) == str(thisValue) && stat != "ID":
			if intValue != 0:
				stats_data[stat] = intValue

	item_ID = DataHandler.item_data[str(a_ItemID)]["ID"]
	item_name = DataHandler.item_data[str(a_ItemID)]["Name"]
	item_info = DataHandler.item_data[str(a_ItemID)]["Info"]

func delete_item():
	queue_free()

# Rotate 90 degress CW
func rotate_item():
	for grid in item_grids:
		var temp_y = grid[0]
		grid[0] = -grid[1]
		grid[1] = temp_y
	rotation_degrees += 90
	if rotation_degrees>=360:
		rotation_degrees = 0

# Snap item to the nearest part of grid
func _snap_to(destination):
	var tween = get_tree().create_tween()
	#separate cases to avoid snapping errors
	if int(rotation_degrees) % 180 == 0:
		destination += IconRect_path.size/2
	else:
		var temp_xy_switch = Vector2(IconRect_path.size.y,IconRect_path.size.x)
		destination += temp_xy_switch/2
	tween.tween_property(self, "global_position", destination, 0.15).set_trans(Tween.TRANS_SINE)
	selected = false

func item_combine_animation():
	animation.play("combine")

func _on_icon_mouse_entered():
	emit_signal("entered_item", self)

func _on_icon_mouse_exited():
	emit_signal("exited_item")
