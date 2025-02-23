extends Node

var saved_position = Vector2.ZERO  # Default value is (0,0)

func save_position(new_position):
	saved_position = new_position
	print("💾 Position Saved:", saved_position)  # Debugging

func get_saved_position():
	print("📌 Getting Saved Position:", saved_position)  # Debugging
	return saved_position
