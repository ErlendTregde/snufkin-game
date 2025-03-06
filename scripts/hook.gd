extends Node2D

var is_cast = false  # If hook is in water
var speed = 200  # Hook movement speed (left/right)
var cast_depth = 300  # How far the hook drops
var reel_speed = 150  # Speed when pulling the hook up
var original_position  # Stores initial position

@onready var sprite = $Sprite2D  # Reference to the hook sprite

func _ready():
	original_position = position  # Store the exact starting position

func _process(delta):
	if is_cast:
		# Move left and right when in water
		if Input.is_action_pressed("ui_left"):
			position.x -= speed * delta
		elif Input.is_action_pressed("ui_right"):
			position.x += speed * delta
		
		# Move down further when cast
		if Input.is_action_pressed("ui_down"):
			position.y += reel_speed * delta  
		
		# Return to rod if up is pressed
		if Input.is_action_pressed("ui_up"):
			return_to_rod()

func cast_hook():
	if not is_cast:
		is_cast = true
		smooth_move(Vector2(position.x, original_position.y + cast_depth))  # Smoothly drop the hook
	else:
		is_cast = false
		return_to_rod()  # Call function to move hook back

func return_to_rod():
	smooth_move(original_position)  # Move back smoothly to original position

func smooth_move(target_position: Vector2):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_position, 0.5)  # Move smoothly in 0.5 sec
