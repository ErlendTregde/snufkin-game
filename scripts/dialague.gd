extends Control

@export var dialogue_file: String = "res://dialogue/moominMama.json"

var dialogue = []
var current_dialogue_id = -1
var active_npc = null

@onready var name_label = $NinePatchRect/Name
@onready var text_label = $NinePatchRect/Text

func _ready():
	$NinePatchRect.visible = false

func load_dialogue():
	var file = FileAccess.open(dialogue_file, FileAccess.READ)
	dialogue = JSON.parse_string(file.get_as_text())

func start_dialogue(npc):
	if active_npc:
		return  # Prevent starting another dialogue if one is active
	
	active_npc = npc
	load_dialogue()
	current_dialogue_id = -1
	$NinePatchRect.visible = true
	next_script()

func _input(event):
	if event.is_action_pressed("ui_accept") and $NinePatchRect.visible:
		next_script()

func next_script():
	current_dialogue_id += 1
	if current_dialogue_id >= len(dialogue):
		$NinePatchRect.visible = false
		active_npc = null
		return

	name_label.text = dialogue[current_dialogue_id]['name']
	text_label.text = dialogue[current_dialogue_id]['text']
