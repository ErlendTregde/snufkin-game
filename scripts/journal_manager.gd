extends Node

## Singleton manager for fishing journal
## Uses scene switching pattern (like map system) with state preservation

const JOURNAL_SCENE_PATH := "res://scenes/fishing_journal.tscn"

func _ready() -> void:
	# Set to always process even when paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	# J key to open journal (don't open if already in journal scene)
	if event.is_action_pressed("open_journal"):
		var current_scene = get_tree().current_scene
		if current_scene and current_scene.scene_file_path == JOURNAL_SCENE_PATH:
			# Already in journal, let fishing_journal.gd handle closing
			return
		
		open_journal()
		if get_viewport():
			get_viewport().set_input_as_handled()

func open_journal() -> void:
	print("📖 Opening journal")
	
	# Save current scene path FIRST
	var current_scene = get_tree().current_scene
	if current_scene and current_scene.scene_file_path:
		Global.previous_scene = current_scene.scene_file_path
		Global.saved_position_scene = current_scene.scene_file_path
		print("📍 Saved previous scene: ", Global.previous_scene)
		
		# If we're in fishing scene, preserve fish state
		if current_scene.scene_file_path.contains("fishing_scene"):
			preserve_fishing_state()
	else:
		push_warning("[JournalManager] Could not save current scene path!")
	
	# Save player position (like map system)
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		# Handle Node2D containers
		if player is Node2D and not player is CharacterBody2D:
			var character_body = player.get_node_or_null("CharacterBody2D")
			if character_body:
				player = character_body
		
		Global.saved_player_position = player.global_position
		print("📍 Saved player position: ", Global.saved_player_position)
	
	# Set flags for return journey
	Global.journal_is_open = true
	Global.from_journal = true
	
	# Change to journal scene (full scene switch like map)
	print("🔄 Changing to journal scene...")
	get_tree().change_scene_to_file(JOURNAL_SCENE_PATH)

func preserve_fishing_state() -> void:
	"""Save active fish and session data before leaving fishing scene"""
	print("🎣 Preserving fishing session state")
	
	Global.fishing_session_active = true
	Global.preserved_fish_data.clear()
	
	# Get all active fish in scene
	var fish_nodes = get_tree().get_nodes_in_group("fishes")
	for fish in fish_nodes:
		if not is_instance_valid(fish):
			continue
		
		# Get fish data
		var fd = fish.get_fish_data() if fish.has_method("get_fish_data") else {}
		
		# Store fish state for restoration
		var fish_state = {
			"id": fd.get("id", ""),
			"position": fish.global_position,
			"scale": fish.scale,
			"move_right": fish.move_right if "move_right" in fish else true
		}
		Global.preserved_fish_data.append(fish_state)
		print("  💾 Saved fish: ", fd.get("name", "Unknown"), " at ", fish_state.position)
	
	print("✅ Preserved %d fish" % Global.preserved_fish_data.size())
