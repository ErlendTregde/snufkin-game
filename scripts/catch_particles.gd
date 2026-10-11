extends CPUParticles2D
# Shimmer particle effect for rare fish catches
# Moomin-themed gentle sparkle

func _ready():
	# Particle settings
	emitting = false
	one_shot = true
	explosiveness = 0.8
	lifetime = 1.5
	amount = 20
	
	# Emission
	emission_shape = EMISSION_SHAPE_SPHERE
	emission_sphere_radius = 50.0
	
	# Movement
	direction = Vector2(0, -1)
	spread = 360
	gravity = Vector2(0, -50)
	initial_velocity_min = 50.0
	initial_velocity_max = 100.0
	
	# Appearance
	scale_amount_min = 0.5
	scale_amount_max = 1.5
	color = Color(1.0, 0.9, 0.5, 1.0)  # Warm gold

func trigger(pos: Vector2, rarity: String = "rare"):
	global_position = pos
	
	# Adjust color based on rarity
	match rarity:
		"uncommon":
			color = Color(0.5, 0.9, 0.5, 1.0)  # Green
			amount = 15
		"rare":
			color = Color(0.6, 0.7, 1.0, 1.0)  # Blue
			amount = 25
		"legendary":
			color = Color(1.0, 0.84, 0.0, 1.0)  # Gold
			amount = 40
			lifetime = 2.0
	
	emitting = true
	
	# Auto-cleanup after lifetime
	await get_tree().create_timer(lifetime + 0.5).timeout
	queue_free()
