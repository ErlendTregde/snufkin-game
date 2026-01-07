extends Area2D

var entered = false  
@onready var label = $Label  

func _ready():
	label.visible = false
	print("🏠 ExitHouse script ready")

func _on_body_entered(body):
	print("🚪 Body entered exit area:", body.name, "Groups:", body.get_groups())
	if body.is_in_group("Player"):  
		entered = true
		label.visible = true
		print("✅ Player detected in exit area")

func _on_body_exited(body):
	print("🚪 Body exited exit area:", body.name)
	if body.is_in_group("Player"):
		entered = false
		label.visible = false
		print("❌ Player left exit area")  

func _process(_delta):
	if entered and Input.is_action_just_pressed("interact"):
		# Find CharacterBody2D inside Player
		var player = get_tree().get_nodes_in_group("Player")  
		if player.size() > 0:
			var character_body = player[0].get_node("CharacterBody2D")  # Get CharacterBody2D
			# Note: We don't save position here as we'll spawn at the saved position from before entering
			print("✅ Exiting House, returning to saved position")
		else:
			print("❌ Error: Player not found in scene!")
		
		get_tree().change_scene_to_file("res://scenes/main.tscn")
