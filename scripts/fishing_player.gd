extends Node2D

@onready var hook = $Hook  # Reference to hook node

var saved_position = Vector2.ZERO  # Default value is (0,0)
var last_hook_position = Vector2.ZERO  # Track hook position changes


func save_position(new_position):
	saved_position = new_position

func get_saved_position():
	return saved_position

func _input(event):
	if event.is_action_pressed("cast_hook"):
		hook.cast_hook()

func _process(_delta):
	# Only redraw if hook position actually changed
	if hook and hook.position != last_hook_position:
		last_hook_position = hook.position
		queue_redraw()

func _draw():
	if hook:
		var start_pos = Vector2(0, 0)  # Fishing rod position (relative to FishingPlayer)
		var end_pos = hook.position  # Hook position (relative to FishingPlayer)
		draw_line(start_pos, end_pos, Color(1, 1, 1), 2)  # White fishing line, thickness 2
