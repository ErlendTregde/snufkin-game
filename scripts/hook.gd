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
	if caught_fish:
		caught_fish.set_process(false)  # Stop fish movement on path
		caught_fish.get_parent().set_process(false)  # Stop PathFollow2D from overriding position
		
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", original_position, 0.5)  
		tween.tween_property(caught_fish, "position", original_position, 0.5)  # Move fish with hook
		
		await tween.finished
		caught_fish.queue_free()  # Remove fish when back at rod
		caught_fish = null
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", original_position, 0.5)


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
	var fish = other_area.get_parent().get_parent().get_parent()  # Now reaches the Fish node
	print("🎣 Hook collided with:", other_area.name, " | Parent:", other_area.get_parent().name, " | Grandparent:", fish.name)
	
	if fish.is_in_group("fishes") and caught_fish == null:
		caught_fish = fish  # Store fish correctly
		print("✅ Fish caught!")  
		return_to_rod()
