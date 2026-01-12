extends Node2D

@onready var path_follow: PathFollow2D = null
@onready var path_2d: Path2D = null
@onready var area = null
@onready var sprite: Sprite2D = null
@export var swim_speed: float = 0.02  # Speed at which fish swims along path
var is_caught: bool = false  # Flag to stop movement when caught
var move_right: bool = true  # Direction fish is moving

# Cache the reversed curve to avoid recreating it
var reversed_curve: Curve2D = null

func _ready():
	add_to_group("fish")  
	
	# Try to find Path2D and PathFollow2D
	path_2d = get_node_or_null("Path2D")
	path_follow = get_node_or_null("Path2D/PathFollow2D")
	if path_follow:
		# Disable automatic rotation based on path
		path_follow.rotates = false
		area = path_follow.get_node_or_null("Area2D")
		sprite = path_follow.get_node_or_null("Sprite2D")

func set_direction(right: bool, size_scale: float = 0.5):
	move_right = right
	
	# Reverse the path for right-to-left movement FIRST
	if path_2d and path_2d.curve and not move_right:
		# Only create reversed curve once
		if not reversed_curve:
			reversed_curve = Curve2D.new()
			reversed_curve.add_point(Vector2(400, 0))
			reversed_curve.add_point(Vector2(-200, 0))
		path_2d.curve = reversed_curve
	
	# Apply size and orientation to sprite AFTER path is set
	if sprite and path_follow:
		# Ensure PathFollow2D never rotates
		path_follow.rotates = false
		path_follow.rotation = 0
		
		# Set sprite orientation
		# Original fish sprite faces RIGHT
		# For left movement: flip to face left
		# For right movement: no flip (keep facing right)
		sprite.flip_h = not move_right
		sprite.flip_v = false
		sprite.rotation = 0
		sprite.scale = Vector2(size_scale, size_scale)

func _process(delta):
	# Don't move if caught
	if is_caught:
		return
	
	if path_follow:
		# Move fish along the path
		path_follow.progress_ratio += swim_speed * delta
		
		# Remove fish when it reaches the end
		if path_follow.progress_ratio >= 1.0:
			queue_free()
