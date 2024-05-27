extends Node

var item_data := {}
var item_grid_data := {}
var item_valid_combo_data := {}
var item_valid_combo_data_2 := {}
var component_product_data := {}
@onready var item_data_path = "res://Data/Item_data.json"

# Called when the node enters the scene tree for the first time.
func _ready():
	load_data(item_data_path)
	set_grid_data()
	set_component_data()
	print(item_valid_combo_data)
	print(item_valid_combo_data_2)

# Load the data file
func load_data(path : String) -> void:
	if not FileAccess.file_exists(path):
		print("Item Data file not found")
	var item_data_file = FileAccess.open(path, FileAccess.READ)
	item_data = JSON.parse_string(item_data_file.get_as_text())
	item_data_file.close()
	#print(item_data)	#check value
	
# Process the json and put the grid information into accessible array format for iterating
func set_grid_data() -> void:
	for item in item_data.keys():
		var temp_grid_array := []
		for point in item_data[item]["Grid"].split("/"):
			temp_grid_array.push_back(point.split(","))
		item_grid_data[item] = temp_grid_array
	#print(item_grid_data)	#check values
	
# Create two dictionaries. 
# item_valid_combo_data: key is first item for a valid pairing, value is the second item of said pairing. 
# This allows for recipe validity to be quickly checked via the first item. 
# component_product_data: key is the two component item, value is result item.
func set_component_data() -> void:
	for item in item_data.keys():
		if item_data[item]["Components"] != "":
			# Populate first dict with all valid pairings
			var firstID = item_data[item]["Components"][0]
			var secondID = item_data[item]["Components"][2]
			
			# One side of combo
			if item_valid_combo_data.has(firstID):
				item_valid_combo_data[firstID].append(secondID)
			else:
				item_valid_combo_data[firstID] = [secondID]
				
			# Reverse side of combo
			if item_valid_combo_data_2.has(secondID):
				item_valid_combo_data_2[secondID].append(firstID)
			else:
				item_valid_combo_data_2[secondID] = [firstID]
			
			# Populate second dict with the item formed by combining a valid pairing
			var resultID = item_data[item]["ID"]
			component_product_data[[firstID, secondID]] = resultID
			# Reverse side of pairing
			component_product_data[[secondID, firstID]] = resultID
	



