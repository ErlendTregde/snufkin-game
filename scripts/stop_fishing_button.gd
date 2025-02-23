extends Button

func _ready():
	# Connect the button to the function
	self.pressed.connect(_on_stop_fishing_pressed)

func _on_stop_fishing_pressed():
	# Change the scene back to main
	get_tree().change_scene_to_file("res://scenes/main.tscn")
