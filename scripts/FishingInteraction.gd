extends Area2D

var entered = false  

@onready var label = $Label 

func _ready():
	label.visible = false  # Hide the label initially

func _on_body_entered(body):
	if body.is_in_group("Player"):  
		entered = true
		label.visible = true  # Show the label when the Player enters

func _on_body_exited(body):
	if body.is_in_group("Player"):
		entered = false
		label.visible = false  # Hide the label when the Player leaves

func _process(_delta):
	if entered and Input.is_action_just_pressed("interact"):
		get_tree().change_scene_to_file("res://scenes/fishing_scene.tscn")
