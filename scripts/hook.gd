extends Node2D

var is_cast = false  # If hook is in water
var speed = 200  # Hook movement speed (left/right)
var cast_depth = 300  # How far the hook drops
var reel_speed = 150  # Speed when pulling the hook up
var original_position  # Stores initial position
var caught_fish = null  # Store reference to caught fish

@onready var sprite = $Sprite2D  
@onready var area = $Area2D  

func _ready():
	original_position = position  # Store the exact starting position
	area.connect("area_entered", Callable(self, "_on_area_entered"))

func _process(delta):
	if is_cast:
		if Input.is_action_pressed("ui_left"):
			position.x -= speed * delta
		elif Input.is_action_pressed("ui_right"):
			position.x += speed * delta
		
		if Input.is_action_pressed("ui_down"):
			position.y += reel_speed * delta  
		
		if Input.is_action_pressed("ui_up"):
			position.y -= reel_speed * delta 

func return_to_rod():
	if caught_fish and caught_fish is PathFollow2D:
		caught_fish.set_process(false)  # Stop automatic movement
		caught_fish.progress = 0  # Reset movement to stop movement
		
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", original_position, 0.5)
		tween.tween_property(caught_fish, "position", original_position, 0.5)

		await tween.finished  # Wait for the movement to complete

		if caught_fish and is_instance_valid(caught_fish):  # Check if still valid before freeing
			caught_fish.queue_free()  # Remove fish when back at rod
			caught_fish = null
	else:
		print("⚠ Error: Caught fish is not PathFollow2D, got:", caught_fish)



func cast_hook():
	if not is_cast:
		is_cast = true
		smooth_move(Vector2(position.x, original_position.y + cast_depth))
	else:
		is_cast = false
		return_to_rod()

func smooth_move(target_position: Vector2):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_position, 0.5)  


func _on_area_2d_area_entered(other_area):
	var fish_path_follow = other_area.get_parent()  # Get parent of Area2D (should be PathFollow2D)

	if fish_path_follow is PathFollow2D:
		caught_fish = fish_path_follow  # Store PathFollow2D, not just Area2D
		print("✅ Fish caught:", caught_fish.name)
		return_to_rod()
	else:
		print("⚠ Error: Expected PathFollow2D but got:", fish_path_follow.name, "| Type:", fish_path_follow.get_class())
