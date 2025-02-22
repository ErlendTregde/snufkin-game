extends Area2D

@export var fishing_scene_path: String = "res://scenes/fishing_scene"

@onready var label = $Label  # Reference the Label node

func _ready():
	label.visible = false  # Hide the label initially

func _on_body_entered(body):
	if body.is_in_group("Player"):  # Detect player using group
		label.visible = true   # Show interaction text

func _on_body_exited(body):
	if body.is_in_group("Player"):
		label.visible = false  # Hide text when the player leaves

func _input(event):
	if event.is_action_pressed("interact") and label.visible:
		get_tree().change_scene_to_file(fishing_scene_path)  # Switch to FishingScene
