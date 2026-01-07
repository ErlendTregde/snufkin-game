extends Node2D

func _ready():
	print("🏠 House Interior Controller Ready")
	
	# Find player and set position
	var player = $Player
	if player:
		print("📍 Player found at position:", player.position)
	
	# Disable player's camera so house interior camera works
	var player_camera = get_tree().get_first_node_in_group("player_camera")
	if player_camera:
		player_camera.enabled = false
		print("✅ Player camera disabled for house interior")
	
	# Make sure house camera is active
	var house_camera = $Camera2D
	if house_camera:
		house_camera.enabled = true
		house_camera.make_current()
		print("✅ House interior camera enabled at position:", house_camera.position)
