extends Node2D

#UI nodes
signal inventory_open()
signal inventory_closed()
var inventoryOpen = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("i") && inventoryOpen == true:
		inventoryOpen = false
		emit_signal("inventory_closed")
	elif Input.is_action_just_pressed("i"):
		inventoryOpen = true
		emit_signal("inventory_open")
