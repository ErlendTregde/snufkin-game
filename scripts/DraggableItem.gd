extends Node2D

@export var can_be_dragged: bool = true
var is_dragging: bool = false

func _ready():
	$Area2D.input_event.connect(_on_input_event)

func _on_input_event(_viewport, event, _shape_idx):
	if can_be_dragged and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed

func _process(_delta):
	if is_dragging:
		global_position = get_global_mouse_position()
