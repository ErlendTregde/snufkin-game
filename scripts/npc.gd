extends Area2D

@export var dialogue_control_path: NodePath
@export var npc_name: String = "Moomin mama"  # Set per NPC in the inspector

var dialogue_control
var player_in_range = false

func _ready():
	dialogue_control = get_node(dialogue_control_path)

func _on_chat_detection_area_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true

func _on_chat_detection_area_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false

func _input(event):
	if event.is_action_pressed("interact"):
		if player_in_range and dialogue_control:
			dialogue_control.start_dialogue(self)
