extends Control

@export var dialogue_file: String = "res://dialogue/moominMama.json"

var dialogue = []
var current_dialogue_id = -1
var active_npc = null
var npc_sprite_path = {}
var player_camera = null
var player_node = null  # Cache player reference
var player_camera_original_position = Vector2.ZERO

@onready var left_character = $LeftCharacter
@onready var right_character = $RightCharacter
@onready var name_label = $NinePatchRect/Name
@onready var text_label = $NinePatchRect/Text
@onready var dialogue_camera = $DialogueCamera 
@onready var back_button = $UIButton 

func _ready():
	player_camera = get_tree().get_first_node_in_group("player_camera")
	player_node = get_tree().get_first_node_in_group("player")
	
	if player_camera:
		player_camera.make_current()
	
	npc_sprite_path = {
		"Moomin mama": preload("res://dialague/Images/idleSmokeing.png"),
	}
	right_character.texture = preload("res://dialague/Images/idleSmokeing.png")
	visible = false
	
	if not back_button.pressed.is_connected(_on_button_pressed):
		back_button.pressed.connect(_on_button_pressed)
		
	back_button.visible = true

func load_dialogue():
	var file = FileAccess.open(dialogue_file, FileAccess.READ)
	if not file:
		return
	var content = file.get_as_text()
	if content.is_empty():
		return
	dialogue = JSON.parse_string(content)

func start_dialogue(npc):
	if active_npc:
		return  # Prevent multiple dialogues

	active_npc = npc
	load_dialogue()
	
	if dialogue == null or dialogue.size() == 0:
		return
		
	current_dialogue_id = -1
	
	# Setup UI
	visible = true
	back_button.visible = true
	
	# Update character sprites
	if npc.npc_name in npc_sprite_path:
		left_character.texture = npc_sprite_path[npc.npc_name]
		left_character.visible = true
	right_character.visible = true
	
	# Camera transition
	if player_camera and player_camera is Camera2D:
		player_camera_original_position = player_camera.position
		
		# Smooth camera transition
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(player_camera, "position", dialogue_camera.position, 0.5)
		await tween.finished
		
		dialogue_camera.make_current()

	# Disable player movement
	if player_node:
		player_node.set_physics_process(false)
		player_node.set_process_input(false)

		if "velocity" in player_node:
			player_node.velocity = Vector2.ZERO
			player_node.move_and_slide()

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
	if not visible:
		return
		
	# Hide UI elements
	visible = false
	back_button.visible = false
	left_character.visible = false
	right_character.visible = false
	
	# Reset dialogue state
	active_npc = null
	current_dialogue_id = -1
	
	# Re-enable player camera and movement
	player_camera = get_tree().get_first_node_in_group("player_camera")
	if player_camera and player_camera is Camera2D:
		player_camera.make_current()
	if player_camera and player_camera is Camera2D:
		player_camera.make_current()
		
		# Smooth camera transition back
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(player_camera, "position", player_camera_original_position, 0.5)
		await tween.finished

	# Re-enable player movement
	if player_node:
		player_node.set_physics_process(true)
		player_node.set_process_input(true)

	get_tree().paused = false








func show_transition():
	var game_camera = get_tree().current_scene.get_node("MainCamera")  # Adjust if needed

	if game_camera:
		var tween = get_tree().create_tween()  # Create a tween dynamically
		tween.tween_property(game_camera, "position", dialogue_camera.position, 0.5).set_trans(Tween.TRANS_CUBIC)
		await tween.finished  # Wait for the transition to complete

	dialogue_camera.current = true  # Switch to dialogue camera


func _on_button_pressed():
	end_dialogue()
