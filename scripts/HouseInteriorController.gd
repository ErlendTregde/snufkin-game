extends Node2D

func _ready():
	# Find player and set position
	var player = $Player
	
	# Disable player's camera so house interior camera works
	var player_camera = get_tree().get_first_node_in_group("player_camera")
	if player_camera:
		player_camera.enabled = false
	
	# Make sure house camera is active
	var house_camera = $Camera2D
	if house_camera:
		house_camera.enabled = true
		house_camera.make_current()
