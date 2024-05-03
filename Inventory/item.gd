extends Node2D

@onready var IconRect_path = $Icon

var item_ID : int
var item_name : String
var item_grids := []
var item_physical : int
var item_magic : int
var item_atkSpd : int
var item_crit : int
var item_mvSpd : int
var item_maxHealth : int
var item_info : String
var selected = false
var grid_anchor = null

# Called when the node enters the scene tree for the first time.
func _ready():
		process_mode = PROCESS_MODE_ALWAYS

# Called every frame. 'delta' is the elapsed time since the previous frame.
# Makes the picked up item follow the cursor. 
func _process(delta):
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)

# Load the image in the assets as an item
func load_item(a_ItemID : int) -> void:
	var Icon_path = "res://Assets/" + DataHandler.item_data[str(a_ItemID)]["Name"] + ".png"
	IconRect_path.texture = load(Icon_path)
	
	# Generate the grid for the image
	for grid in DataHandler.item_grid_data[str(a_ItemID)]:
		var converter_array := []
		for i in grid :
			converter_array.push_back(int(i))
		item_grids.push_back(converter_array)
	#print(item_grids)
	
	# Andrew wuz here
	# Extra functionality to load in all the data for an item
	
	item_name = DataHandler.item_data[str(a_ItemID)]["Name"]
	item_physical = int(DataHandler.item_data[str(a_ItemID)]["Physical"])
	item_magic = int(DataHandler.item_data[str(a_ItemID)]["Magic"])
	item_atkSpd = int(DataHandler.item_data[str(a_ItemID)]["Attack Speed"])
	item_crit = int(DataHandler.item_data[str(a_ItemID)]["Crit"])
	item_mvSpd = int(DataHandler.item_data[str(a_ItemID)]["Move Speed"])
	item_maxHealth = int(DataHandler.item_data[str(a_ItemID)]["Max Health"])
	item_info = DataHandler.item_data[str(a_ItemID)]["Info"]

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
