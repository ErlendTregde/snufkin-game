extends Area2D

var entered = false  
var player_character_body = null  # Cache CharacterBody2D reference
@onready var label = $Label  

func _ready():
	label.visible = false

func _on_body_entered(body):
	if body.is_in_group("Player"):  
		entered = true
		player_character_body = body
		label.visible = true

func _on_body_exited(body):
	if body.is_in_group("Player"):
		entered = false
		player_character_body = null
		label.visible = false

func _process(_delta):
	if entered and Input.is_action_just_pressed("interact"):
		# Don't save position - use the one saved before entering house
		get_tree().change_scene_to_file("res://scenes/main.tscn")
