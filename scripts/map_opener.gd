extends Node

# This script handles opening the map from any scene

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_M:
			open_map()

func open_map():
	# Save player position if in Main scene
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		# If player is a Node2D container, get the CharacterBody2D child
		if player is Node2D and not player is CharacterBody2D:
			var character_body = player.get_node_or_null("CharacterBody2D")
			if character_body:
				player = character_body
		
		print("[MapOpener] Player found. Current position: ", player.global_position)
		print("[MapOpener] Player local position: ", player.position)
		Global.saved_player_position = player.global_position
		print("[MapOpener] Saved player position: ", Global.saved_player_position)
	
	# Save which scene we're in so we can return
	var current_scene = get_tree().current_scene
	if current_scene:
		Global.previous_scene = current_scene.scene_file_path
		Global.saved_position_scene = current_scene.scene_file_path  # Track which scene this position belongs to
		print("[MapOpener] Opening map from: ", Global.previous_scene)
		
		# Change to map scene
		get_tree().change_scene_to_file("res://scenes/map_scene.tscn")