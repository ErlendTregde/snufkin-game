extends Area2D

@export var dialogue_control_path: NodePath
@export var npc_name: String = "Moomin mama"  # Set per NPC in the inspector

var dialogue_control

func _ready():
	dialogue_control = get_node(dialogue_control_path)

func _input(event):
	if event.is_action_pressed("interact") and has_overlapping_bodies():
		dialogue_control.start_dialogue(self)
