extends Area2D

var entered = false  
@onready var label = $Label  

func _ready():
	label.visible = false  

func _on_body_entered(body):
	if body.is_in_group("Player"):  
		entered = true
		label.visible = true  

func _on_body_exited(body):
	if body.is_in_group("Player"):
		entered = false
		label.visible = false  

func _process(_delta):
	if entered and Input.is_action_just_pressed("interact"):
		# Find CharacterBody2D inside Player
		var player = get_tree().get_nodes_in_group("Player")  
		if player.size() > 0:
			var character_body = player[0].get_node("CharacterBody2D")  # Get CharacterBody2D
			Global.save_position(character_body.global_position)  # Save the correct position
			print("✅ Player Position Saved Before Fishing:", character_body.global_position)  # Debugging
		else:
			print("❌ Error: Player not found in scene!")
		
		get_tree().change_scene_to_file("res://scenes/fishing_scene.tscn")
