extends Node2D

@export var can_be_dragged: bool = true
var is_dragging: bool = false  # Tracks whether the item is being dragged

func _ready():
	# Connect the Area2D input_event signal
	$Area2D.input_event.connect(_on_input_event)

func _on_input_event(viewport, event, shape_idx):
	if can_be_dragged and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:  # Correct MouseButton usage
			is_dragging = event.pressed  # Start or stop dragging based on mouse state

func _process(delta):
	if is_dragging:
		global_position = get_global_mouse_position()  # Follow mouse position
