extends Control

@export var dialogue_file: String = "res://dialogue/moominMama.json"

var dialogue = []
var current_dialogue_id = -1
var active_npc = null
var npc_sprite_path = {}

@onready var left_character = $LeftCharacter
@onready var right_character = $RightCharacter
@onready var name_label = $NinePatchRect/Name
@onready var text_label = $NinePatchRect/Text
@onready var dialogue_camera = $DialogueCamera 

func _ready():
	# Preload NPC sprites for easy swapping
	npc_sprite_path = {
		"Moomin mama": preload("res://dialague/Images/idleSmokeing.png"),
		#"Other NPC": preload("res://sprites/other_npc.png") # Example for future NPCs
	}
	right_character.texture = preload("res://dialague/Images/idleSmokeing.png") # Snufkin always on the right
	visible = false  # Hide the UI at start

func load_dialogue():
	var file = FileAccess.open(dialogue_file, FileAccess.READ)
	if not file:
		print("Error: Could not open dialogue file: ", dialogue_file)
		return
	var content = file.get_as_text()
	if content.is_empty():
		print("Error: Dialogue file is empty!")
		return
	dialogue = JSON.parse_string(content)
	if dialogue == null:
		print("Error: Failed to parse JSON!")

func start_dialogue(npc):
	if active_npc:
		return  # Prevent multiple dialogues

	active_npc = npc
	load_dialogue()
	current_dialogue_id = -1
	visible = true  # Show UI

	# Get player's camera
	var game_camera = get_tree().get_first_node_in_group("player_camera")
	if game_camera and game_camera is Camera2D:
		var tween = get_tree().create_tween()  # Smooth transition
		tween.tween_property(game_camera, "position", dialogue_camera.position, 0.5).set_trans(Tween.TRANS_CUBIC)
		await tween.finished  # Wait for transition to complete

		dialogue_camera.make_current()  # Switch to dialogue camera

	# Disable player movement
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false)  # Disable physics (movement)
		player.set_process_input(false)  # Disable input handling

	# Ensure UI stays on top
	z_index = 100
	next_script()





func _input(event):
	if event.is_action_pressed("ui_accept") and visible:
		next_script()
	elif event.is_action_pressed("ui_cancel") and visible:
		end_dialogue()

func next_script():
	current_dialogue_id += 1
	if current_dialogue_id >= len(dialogue):
		end_dialogue()
		return

	if "name" in dialogue[current_dialogue_id] and "text" in dialogue[current_dialogue_id]:
		name_label.text = dialogue[current_dialogue_id]['name']
		text_label.text = dialogue[current_dialogue_id]['text']
	else:
		print("Error: Missing 'name' or 'text' in dialogue entry!")
	
func end_dialogue():
	visible = false
	active_npc = null

	# Get player's camera
	var game_camera = get_tree().get_first_node_in_group("player_camera")
	if game_camera and game_camera is Camera2D:
		var tween = get_tree().create_tween()  # Smooth transition back
		tween.tween_property(dialogue_camera, "position", game_camera.position, 0.5).set_trans(Tween.TRANS_CUBIC)
		await tween.finished

		game_camera.make_current()  # Switch back to player camera

	# Re-enable player movement
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(true)  # Enable physics (movement)
		player.set_process_input(true)  # Enable input handling

	get_tree().paused = false  # Unpause the game







func show_transition():
	var game_camera = get_tree().current_scene.get_node("MainCamera")  # Adjust if needed

	if game_camera:
		var tween = get_tree().create_tween()  # Create a tween dynamically
		tween.tween_property(game_camera, "position", dialogue_camera.position, 0.5).set_trans(Tween.TRANS_CUBIC)
		await tween.finished  # Wait for the transition to complete

	dialogue_camera.current = true  # Switch to dialogue camera
