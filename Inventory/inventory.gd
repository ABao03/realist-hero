extends Control

# GUI
@onready var slot_scene = preload("res://Inventory/slot.tscn")
@onready var grid_container = $Background/MarginContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var item_scene = preload("res://Inventory/item.tscn")
@onready var scroll_container = $Background/MarginContainer/VBoxContainer/ScrollContainer
@onready var col_count = grid_container.columns #save column number
@onready var grid_container2 = $Background2/MarginContainer/VBoxContainer/ScrollContainer/GridContainer

# Placing Items
var item_held = null
var current_slot = null
var can_place := false
var icon_anchor : Vector2
var is_open = false

# Tracking Items
var grid_array := []
var currentInventory = []
var componentInventory = []
@onready var animationTimer = $Timer
var tempItem1
var tempItem2

# Send upgrades to Player node
signal pass_upgrade(upgrade)
@onready var players = get_tree().get_nodes_in_group("player")
var player

# Sound
@onready var snd = $Snd
@onready var combineSnd = $CombineSnd

# Enemy spawner resume spawning
@onready var spawner = get_tree().get_first_node_in_group("spawner")
signal start_spawning()

# Fire player bullets
@onready var origins = get_tree().get_nodes_in_group("weapon_origin")
var weapon_origin

# DEBUG
@onready var itemArray = [3, 1]
@onready var index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	for thisPlayer in players:
		if thisPlayer != null:
			player = thisPlayer
	
	for thisOrigin in origins:
		if thisOrigin != null:
			weapon_origin = thisOrigin
	connect("pass_upgrade",Callable(player,"update_stats"))
	connect("start_spawning",Callable(spawner,"start_spawning"))
	for i in range(80):
		create_slot()
	visible = false
	

# Open and close inventory
func open():
	visible = true
	is_open = true
	player.playerPaused = true
	snd.volume_db = -7
	snd.stream = load("res://Assets/SoundEffects/inventoryOpened.mp3")
	snd.play()

func close():
	if animationTimer.is_stopped() == true:
		visible = false
		is_open = false
		player.playerPaused = false
		snd.volume_db = 0
		snd.stream = load("res://Assets/SoundEffects/inventoryClosed.mp3")
		snd.play()
		emit_signal("start_spawning")

func _process(delta):
	if item_held:
		if Input.is_action_just_pressed("mouse_rightclick"):
			rotate_item()
		
		if Input.is_action_just_pressed("mouse_leftclick"):
			if scroll_container.get_global_rect().has_point(get_global_mouse_position()):
				place_item()
	else:
		if Input.is_action_just_pressed("mouse_leftclick"):
			if scroll_container.get_global_rect().has_point(get_global_mouse_position()):
				pick_item()
	
	if Input.is_action_just_pressed("i"):
		if is_open:
			close()
		else:
			open()
	
	if item_held:
		if Input.is_action_pressed("delete"):
			if currentInventory.has(item_held):
				currentInventory.erase(item_held)
			item_held.delete_item()
			item_held = null
				
# Debug
func create_slot():
	var new_slot = slot_scene.instantiate()
	new_slot.slot_ID = grid_array.size()
	grid_container.add_child(new_slot)
	grid_array.push_back(new_slot)
	new_slot.slot_entered.connect(_on_slot_mouse_entered)
	new_slot.slot_exited.connect(_on_slot_mouse_exited)

# Scan hovered slots and change their color depending on if they're empty or not
func _on_slot_mouse_entered(a_Slot):
	icon_anchor = Vector2(10000,100000)
	current_slot = a_Slot
	if item_held:
		check_slot_availability(current_slot)
		set_grids.call_deferred(current_slot)

# When exiting a previously-hovered slot with the mouse, reset the slot's color back to the default clear
func _on_slot_mouse_exited(a_Slot):
	clear_grid()
	
	if not grid_container.get_global_rect().has_point(get_global_mouse_position()):
		current_slot = null

# Debug spawn item button
func _on_button_spawn_pressed():
	# These three lines handle all the instantiation
	var new_item = item_scene.instantiate()
	add_child(new_item)
	#new_item.load_item(randi_range(1,8))    #randomize this for different items to spawn
	new_item.load_item(itemArray[index])
	index += 1
	
	# This places the item into the player's hand
	new_item.selected = true
	item_held = new_item
	
# Called via signal whenever the player chooses an upgrade in the upgrade options
func upgrade_character(upgrade):
	if item_held != null:
		item_held.delete_item()
		item_held = null
		
	var new_item = item_scene.instantiate()
	add_child(new_item)
	new_item.load_item(int(upgrade["ID"]))
	new_item.selected = true
	item_held = new_item
	
# Checks to see if the item can be placed in the slot 
func check_slot_availability(a_Slot):
	for grid in item_held.item_grids:
		var grid_to_check = a_Slot.slot_ID + grid[0] + grid[1] * col_count
		var line_switch_check = a_Slot.slot_ID % col_count + grid[0]
		if line_switch_check < 0 or line_switch_check >= col_count:
			can_place = false
			return
		if grid_to_check < 0 or grid_to_check >= grid_array.size():
			can_place = false
			return
		if grid_array[grid_to_check].state == grid_array[grid_to_check].States.TAKEN:
			can_place = false
			return
	can_place = true
	
# Draws the grid inventory
func set_grids(a_Slot):
	for grid in item_held.item_grids:
		var grid_to_check = a_Slot.slot_ID + grid[0] + grid[1] * col_count
		if grid_to_check < 0 or grid_to_check >= grid_array.size():
			continue
		#make sure the check don't wrap around boarders
		var line_switch_check = a_Slot.slot_ID % col_count + grid[0]
		if line_switch_check < 0 or line_switch_check >= col_count:
			continue
		
		if can_place:
			grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.FREE)
			#save anchor for snapping
			if grid[1] < icon_anchor.x: icon_anchor.x = grid[1]
			if grid[0] < icon_anchor.y: icon_anchor.y = grid[0]
				
		else:
			grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.TAKEN)

func clear_grid():	
	for grid in grid_array:
		grid.set_color(grid.States.DEFAULT)

func rotate_item():
	if visible == true:
		item_held.rotate_item()
		clear_grid()
		if current_slot:
			_on_slot_mouse_entered(current_slot)

# Handles the snapping of the item to the GUI grid as well as adding the stats to the player
func place_item():
	if visible == true:
		# For the purpose of wiping item info at the end (or not)
		var createdCombo = false
		
		if not can_place or not current_slot: 
			snd.stream = load("res://Assets/SoundEffects/itemFailedToPlace.wav")
			snd.play()
			return
			
		#for changing scene tree
		item_held.get_parent().remove_child(item_held)
		grid_container.add_child(item_held)
		item_held.global_position = get_global_mouse_position()

		var calculated_grid_id = current_slot.slot_ID + icon_anchor.x * col_count + icon_anchor.y
		
		item_held._snap_to(grid_array[calculated_grid_id].global_position)
		
		# Creates the boxes that are used to snap to the grid
		item_held.grid_anchor = current_slot
		for grid in item_held.item_grids:
			var grid_to_check = current_slot.slot_ID + grid[0] + grid[1] * col_count
			grid_array[grid_to_check].state = grid_array[grid_to_check].States.TAKEN 
			grid_array[grid_to_check].item_stored = item_held
		
		# Pass item stat data to the Player node so that stuff can get calculated
		if not currentInventory.has(item_held):
			# Place item into array that keeps track of which items are currently in inventory
			currentInventory.append(item_held)
			recalculateStats()
			emit_signal("pass_upgrade", PlayerStatDataHandler.addedStats)
			
			weapon_origin.create_timer(item_held.item_fire_rate, item_held.item_name)
			
			createdCombo = check_combos(item_held)
		
		# Needs a conditional, or else it'll auto-wipe the item at the end even if a new one was made via combo
		if createdCombo == false:
			item_held = null
		
		snd.stream = load("res://Assets/SoundEffects/itemPlaced.mp3")
		snd.volume_db = 10
		snd.play()
		clear_grid()

# Recalculate stats each time an item is placed in the grid
func recalculateStats():
	# old code with number stats
	# Set to default each time
	for stat in PlayerStatDataHandler.addedStats:
		# Add the component items if they exist (the default is at base, meaning they'll only exist if it's bigger)
		if PlayerStatDataHandler.addedStats[stat] <= PlayerStatDataHandler.combinedComponentStats[stat]:
			PlayerStatDataHandler.addedStats[stat] = PlayerStatDataHandler.combinedComponentStats[stat]
		# Add the base stats if there are no component items
		# (do base stats need to be separate from combined stats? yes, they do need to be separate.)
		else:
			PlayerStatDataHandler.addedStats[stat] = PlayerStatDataHandler.baseStats[stat]
	
	# Add the data of each item in the inventory to the Autoloaded file
	#for item in currentInventory:
		#add_data(item, PlayerStatDataHandler.addedStats)

# Used when the item is picked up by the player
func pick_item():
	if visible == true:
		# Check if slot is empty
		if not current_slot or not current_slot.item_stored: 
			return
		
		# Assign item to item_held
		item_held = current_slot.item_stored
		item_held.selected = true
		
		# Move node in the scene tree
		item_held.get_parent().remove_child(item_held)
		add_child(item_held)
		item_held.global_position = get_global_mouse_position()
		
		# Free up grid
		for grid in item_held.item_grids:
			var grid_to_check = item_held.grid_anchor.slot_ID + grid[0] + grid[1] * col_count # use grid anchor instead of current slot to prevent bug
			grid_array[grid_to_check].state = grid_array[grid_to_check].States.FREE 
			grid_array[grid_to_check].item_stored = null
		
		check_slot_availability(current_slot)
		set_grids.call_deferred(current_slot)

# Debug
func _on_add_slot_pressed():
	create_slot()

# Deleting item from inventory (do not mix up with delete_item function in item scene)
func delete_from_inventory(thisItem):
	if visible == true:
		if currentInventory.has(thisItem):
			# An attempt at clearing the slots occupied by thisItem in inventory
			for grid in thisItem.item_grids:
				var grid_to_check = thisItem.grid_anchor.slot_ID + grid[0] + grid[1] * col_count # use grid anchor instead of current slot to prevent bug
				grid_array[grid_to_check].state = grid_array[grid_to_check].States.FREE 
				grid_array[grid_to_check].item_stored = null
				
			# Wiping from currentInventory array
			currentInventory.erase(thisItem)
			thisItem.delete_item()
				
			# Update grid
			#set_grids.call_deferred(current_slot)
		
# Check if a combo is present among the current items in inventory after adding in newItem
func check_combos(newItem):
	# Keep track of both the normal and reverse side of the possible combos 
	var possibleCombos = DataHandler.item_valid_combo_data
	var reversePossibleCombos = DataHandler.item_valid_combo_data_2
	var keyID = newItem.item_ID
	var foundCombo = false
	
	# Normal order check
	if possibleCombos.has(keyID):
		for item in currentInventory:
			for id in possibleCombos[keyID]:
				# If valid combo found, combine the items
				if id == item.item_ID && foundCombo == false:
					combineItems(newItem, item)
					foundCombo = true
					
	# Reverse order check
	if reversePossibleCombos.has(keyID):
		for item in currentInventory:
			for id in reversePossibleCombos[keyID]:
				if id == item.item_ID && foundCombo == false:
					combineItems(newItem, item)
					foundCombo = true
	
	return foundCombo

# Combines two items into the new combined item (combination already found)
func combineItems(item1, item2):
	componentInventory.append(DataHandler.deep_clone(item1))
	componentInventory.append(DataHandler.deep_clone(item2))
	
	tempItem1 = item1
	tempItem2 = item2
	
	# Keep the stats from the combined item's components
	add_data(item1, PlayerStatDataHandler.combinedComponentStats)
	add_data(item2, PlayerStatDataHandler.combinedComponentStats)
	
	# Play an animation on the item
	item1.item_combine_animation()
	item2.item_combine_animation()
	animationTimer.start()

# Adding item stats to a given Autoloaded database
func add_data(item, database):
	pass
	#var stat = item.item_stat
	# don't need to loop one variable
	#for stat in data:
		# old stats
		#if stat == "Physical":
			#var damage = data.get(stat)
			#if damage > 2:
				#damage = int(damage)
				#database[stat] += damage
			#else:
				#database[stat] *= damage
			#
		#if stat == "Magic":
			#var damage = data.get(stat)
			#if damage > 2:
				#damage = int(damage)
				#database[stat] += damage
			#else:
				#database[stat] *= damage
				#
		#if stat == "Attack Speed":
			#database[stat] *= data.get(stat)
			#
		#if stat == "Crit":
			#database[stat] *= data.get(stat)
			
	#if stat == "Move Speed":
		## if float(data.get(stat)) > 2:
		#if float(stat) > 2:
			##database[stat] += data.get(stat)
			#database[stat] += item.item_stat_amount
		#else:
			##database[stat] *= data.get(stat)
			#database[stat] *= item.item_stat_amount
			#
	#if stat == "Max Health":
		## if float(data.get(stat)) > 2:
		#if float(stat) > 2:
			##database[stat] += data.get(stat)
			#database[stat] += item.item_stat_amount
		#else:
			##database[stat] *= data.get(stat)
			#database[stat] *= item.item_stat_amount
		
		# old stat
		#if stat == "Defense":
			#if float(data.get(stat)) > 2:
				#database[stat] += data.get(stat)
			#else:
				#database[stat] *= data.get(stat)
			
	#if stat == "Points":
		##database[stat] += data.get(stat)
		#database[stat] += item.item_stat_amount

# Makes it so that items only get deleted after the animation finishes, not before
func _on_timer_timeout():
	combineSnd.stream = load("res://Assets/SoundEffects/itemCombine.wav")
	combineSnd.play()
	
	# Fetch the new item from the data handler dictionary.
	var combinedItemID = DataHandler.component_product_data[[tempItem1.item_ID, tempItem2.item_ID]]
	# Instantiate the new item into the scene. 
	var combinedItem = item_scene.instantiate()
	add_child(combinedItem)
	
	# Load the new item's data. Place it into the player's hand. 
	combinedItem.load_item(int(combinedItemID))
	combinedItem.selected = true
	item_held = combinedItem
	
	# Delete the item elements. 
	delete_from_inventory(tempItem1)
	delete_from_inventory(tempItem2)
	
	tempItem1 = null
	tempItem2 = null
