extends Area2D

@export var dialogue_control_path: NodePath
@export var npc_name: String = "Moomin mama"  # Set per NPC in the inspector
@export var npc_portrait: Texture2D  # NPC portrait for dialogue
@export var accepts_fish: bool = true  # Whether this NPC accepts fish deliveries

var dialogue_control
var player_in_range = false
var interact_prompt
var fish_delivery_ui = null

func _ready():
	dialogue_control = get_node(dialogue_control_path)
	interact_prompt = get_node("../InteractPrompt")
	# Set process input to run even when paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_chat_detection_area_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true
		if interact_prompt:
			interact_prompt.visible = true

func _on_chat_detection_area_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false
		if interact_prompt:
			interact_prompt.visible = false

func _input(event):
	# Only trigger when E is pressed, player is in range, and not already in dialogue
	if event.is_action_pressed("interact") and not event.is_echo():
		if player_in_range and dialogue_control and not dialogue_control.visible:
			# Hide interact prompt when dialogue opens
			if interact_prompt:
				interact_prompt.visible = false
			dialogue_control.start_dialogue(self)
	
	# F key to open fish delivery (while not in dialogue)
	elif event.is_action_pressed("fish") and not event.is_echo():
		if player_in_range and accepts_fish and not dialogue_control.visible:
			open_fish_delivery()

func open_fish_delivery():
	# Always create a fresh instance
	var delivery_scene = load("res://scenes/fish_delivery_ui.tscn")
	if not delivery_scene:
		print("⚠️ Fish delivery UI scene not found")
		return
	
	fish_delivery_ui = delivery_scene.instantiate()
	get_tree().root.add_child(fish_delivery_ui)
	
	if fish_delivery_ui:
		fish_delivery_ui.delivery_closed.connect(_on_delivery_closed)
		if fish_delivery_ui.has_method("show_delivery_ui"):
			fish_delivery_ui.show_delivery_ui(npc_name)

func _on_delivery_closed():
	# Remove the UI completely
	if fish_delivery_ui and is_instance_valid(fish_delivery_ui):
		fish_delivery_ui.queue_free()
		fish_delivery_ui = null
	
	# Re-show interact prompt
	if player_in_range and interact_prompt:
		interact_prompt.visible = true
