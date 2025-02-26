extends Node2D

var is_cast = false  # If hook is in water
var speed = 200  # Hook movement speed
var cast_depth = 400  # How far the hook drops

@onready var sprite = $Sprite2D  # Reference to the hook sprite

func _process(delta):
	if is_cast:
		if Input.is_action_pressed("ui_left"):
			position.x -= speed * delta
		elif Input.is_action_pressed("ui_right"):
			position.x += speed * delta

func cast_hook():
	if not is_cast:
		is_cast = true
		position.y += cast_depth  # Drop the hook
	else:
		is_cast = false
		position.y -= cast_depth  # Pull hook back up
		
func _on_Area2D_body_entered(body):
	if body.is_in_group("fish"):  
		print("🎣 Fish Caught!")
		body.queue_free()  # Remove fish when caught
		
		
