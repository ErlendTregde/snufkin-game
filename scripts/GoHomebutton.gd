extends Button

func _ready():
	self.pressed.connect(_on_stop_fishing_pressed)

func _on_stop_fishing_pressed():
	# Don't save position - use the one saved before entering fishing
	get_tree().change_scene_to_file("res://scenes/main.tscn")
