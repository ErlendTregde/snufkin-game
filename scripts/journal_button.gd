extends Button
# Button to open fishing journal from main menu or pause menu

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	open_journal()

func open_journal():
	# Save current state using Global system (same as map)
	var current_scene = get_tree().current_scene
	if current_scene:
		Global.previous_scene = current_scene.scene_file_path
		Global.saved_position_scene = current_scene.scene_file_path
		print("[JournalButton] Opening journal from: ", Global.previous_scene)
	
	# Save player position if player exists
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		# Handle both direct CharacterBody2D and Node2D containers
		if player is Node2D and not player is CharacterBody2D:
			var character_body = player.get_node_or_null("CharacterBody2D")
			if character_body:
				player = character_body
		
		Global.saved_player_position = player.global_position
		print("[JournalButton] Saved player position: ", Global.saved_player_position)
	
	# Set journal flags
	Global.journal_is_open = true
	Global.from_journal = true
	
	# Load journal scene
	get_tree().change_scene_to_file("res://scenes/fishing_journal.tscn")

