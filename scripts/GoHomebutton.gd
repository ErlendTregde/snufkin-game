extends Button

func _ready():
	self.pressed.connect(_on_stop_fishing_pressed)

func _on_stop_fishing_pressed():
	# ✅ Find Fishing Player using the group name
	var fishing_players = get_tree().get_nodes_in_group("FishingPlayer")
	if fishing_players.size() > 0:
		var fishing_player = fishing_players[0]  # First found fishing player
		Global.save_position(fishing_player.global_position)  # Save position
		print("✅ Leaving fishing scene. Position saved:", fishing_player.global_position)
	else:
		print("❌ Error: Fishing Player not found in scene!")  # Debugging

	# Change back to the main scene
	get_tree().change_scene_to_file("res://scenes/main.tscn")
