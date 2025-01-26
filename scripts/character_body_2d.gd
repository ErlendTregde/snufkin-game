extends CharacterBody2D

# Player constants
const SPEED = 1000.0
const GRAVITY = 800.0
const JUMP_FORCE = -500.0  # Jump strength

# Reference to the AnimatedSprite2D node
@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Get the horizontal input direction (-1 for left, 1 for right, 0 for idle)
	var direction := Input.get_axis("ui_left", "ui_right")

	# Update horizontal velocity
	velocity.x = direction * SPEED

	# Apply gravity to the vertical velocity
	velocity.y += GRAVITY * delta

	# Jumping logic
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_FORCE

	# Play animations based on movement
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		elif direction < 0:
			animated_sprite.play("run_left")
		else:
			animated_sprite.play("run_right")
	else:
		animated_sprite.play("jump")  # Optional jump animation

	# Apply movement and handle collisions
	move_and_slide()
