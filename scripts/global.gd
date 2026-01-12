extends Node

var saved_position = Vector2.ZERO  # Default value is (0,0)

func save_position(new_position):
	saved_position = new_position

func get_saved_position():
	return saved_position
