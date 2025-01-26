extends CharacterBody2D

# Player constants
const SPEED = 1000
const GRAVITY = 800.0

# Reference to the AnimatedSprite2D node
@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Get the horizontal input direction (-1 for left, 1 for right, 0 for idle)
	var direction := Input.get_axis("ui_left", "ui_right")

	# Update velocity
	velocity.x = direction * SPEED

	# Play animations based on movement
	if direction == 0:
		# Player is idle
		animated_sprite.play("idle")
	else:
		# Check the direction to determine running animation
		if direction < 0:
			animated_sprite.play("run_left")
		else:
			animated_sprite.play("run_right")

	# Apply movement
	move_and_slide()
