extends Node2D

# Exported Parameters - Configure in Inspector
@export_category("Leaf Textures")
@export var leaf_textures: Array[Texture2D] = []

@export_category("Spawn Settings")
@export_range(10, 200) var particle_amount: int = 30  # Fewer leaves
@export_range(1.0, 8.0) var particle_lifetime: float = 2.5  # Shorter - leaves cross fast
@export_range(0.1, 5.0) var spawn_rate: float = 1.0

@export_category("Fall Physics")
@export_range(0, 200) var gravity_strength: float = 50.0  # Minimal gravity
@export_range(-1000, 0) var wind_strength: float = -600.0  # VERY strong left wind
@export_range(0, 100) var turbulence_strength: float = 25.0  # Less turbulence for faster flow

@export_category("Leaf Appearance")
@export var min_leaf_scale: float = 0.3
@export var max_leaf_scale: float = 0.8
@export_range(0, 360) var rotation_speed_min: float = 45.0
@export_range(0, 360) var rotation_speed_max: float = 180.0

@export_category("Emission Area")
@export var emission_height: float = 800.0  # Vertical spawn range (top-right to middle-right)
@export var x_offset_from_right: float = 50.0  # How far from right edge to spawn

@export_category("Camera Following")
@export var follow_camera: bool = true
@export var target_camera: Camera2D = null  # Manually assign player's camera

@export_category("Collision Detection")
@export var enable_ground_collision: bool = true
@export var ground_node_name: String = "Ground"  # Name of ground node to detect

@onready var particles: GPUParticles2D = $GPUParticles2D
var camera: Camera2D = null
var ground_node: Node2D = null
var ground_y: float = 1000.0  # Default ground level

func _ready():
	setup_particles()
	find_camera()
	find_ground()
	
func setup_particles():
	if not particles:
		return
		
	# Create AnimatedTexture from array of leaf textures
	if leaf_textures.size() > 0:
		var animated_texture = AnimatedTexture.new()
		animated_texture.frames = leaf_textures.size()
		
		for i in range(leaf_textures.size()):
			animated_texture.set_frame_texture(i, leaf_textures[i])
			animated_texture.set_frame_duration(i, particle_lifetime)
		
		particles.texture = animated_texture
	
	# Configure basic particle settings
	particles.amount = particle_amount
	particles.lifetime = particle_lifetime
	particles.explosiveness = 0.0
	particles.randomness = 0.8  # Slightly less random for more consistent spawning
	particles.fixed_fps = 60
	particles.local_coords = false  # CRITICAL: Particles stay in world space when emitter moves
	particles.visibility_rect = Rect2(-3000, -emission_height/2, 3500, emission_height * 2)
	
	# Create and configure ParticleProcessMaterial
	var material = ParticleProcessMaterial.new()
	
	# Emission shape - vertical line on right side
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	material.emission_box_extents = Vector3(20, emission_height / 2, 0)
	
	# Particle direction - FAST LEFT movement
	material.direction = Vector3(-1, 0.1, 0)  # Almost pure left, minimal down
	material.spread = 8.0
	material.initial_velocity_min = 400.0  # Very fast
	material.initial_velocity_max = 600.0  # Extremely fast
	
	# Gravity for gentle falling as they blow left
	material.gravity = Vector3(wind_strength, gravity_strength, 0)
	
	# Minimal damping for fast movement
	material.damping_min = 2.0
	material.damping_max = 5.0
	
	# Light turbulence for subtle wind variation
	material.turbulence_enabled = true
	material.turbulence_noise_strength = turbulence_strength
	material.turbulence_noise_scale = 8.0  # Large scale for gentle variation
	material.turbulence_noise_speed = Vector3(-2.0, 0.2, 0)  # Fast left flow
	material.turbulence_influence_min = 0.1  # Minimal influence
	material.turbulence_influence_max = 0.25
	
	# Reduced tangential acceleration
	material.tangential_accel_min = -5.0
	material.tangential_accel_max = 5.0
	
	# Scale variation
	material.scale_min = min_leaf_scale
	material.scale_max = max_leaf_scale
	
	# Smooth rotation (spinning as they flow)
	material.angular_velocity_min = rotation_speed_min * 0.5  # Slower, smoother spin
	material.angular_velocity_max = rotation_speed_max * 0.5
	
	# Inherit velocity for smooth transitions
	material.inherit_velocity_ratio = 0.3
	
	# Color modulation (optional - keeps original colors)
	material.color = Color(1, 1, 1, 1)
	
	# Collision with ground (rigid body mode)
	if enable_ground_collision:
		material.collision_mode = ParticleProcessMaterial.COLLISION_RIGID
		material.collision_friction = 0.8
		material.collision_bounce = 0.2
	
	# Apply material
	particles.process_material = material
	particles.emitting = true

# Update parameters in real-time when changed in inspector
func _process(_delta):
	if Engine.is_editor_hint():
		setup_particles()
	elif follow_camera and camera:
		follow_camera_position()

func find_ground():
	if not enable_ground_collision:
		return
	
	# Try to find ground node by name
	var root = get_tree().root
	ground_node = find_node_by_name(root, ground_node_name)
	
	if ground_node:
		# Get the Y position of the ground
		if ground_node is StaticBody2D or ground_node is CharacterBody2D:
			ground_y = ground_node.global_position.y
		else:
			ground_y = ground_node.global_position.y
		print("FallingLeaves: Found ground at Y: ", ground_y)
	else:
		print("FallingLeaves: Ground node '", ground_node_name, "' not found. Using default Y: ", ground_y)

func find_node_by_name(node: Node, search_name: String) -> Node:
	if node.name == search_name:
		return node
	
	for child in node.get_children():
		var result = find_node_by_name(child, search_name)
		if result:
			return result
	
	return null

func find_camera():
	# Use manually assigned camera first
	if target_camera:
		camera = target_camera
		return
	
	# Look for camera in "player_camera" group (most specific)
	camera = get_tree().get_first_node_in_group("player_camera")
	if camera:
		return
	
	# Try to find player's camera by looking for player node
	var player = get_tree().get_first_node_in_group("player")
	if player:
		camera = find_camera_in_node(player)
		if camera:
			return
	
	# Last resort: search entire tree
	var root = get_tree().root
	camera = find_camera_recursive(root)
	
	if not camera:
		push_warning("FallingLeaves: No Camera2D found. Assign camera manually in inspector.")

func find_camera_in_node(node: Node) -> Camera2D:
	if node is Camera2D:
		return node
	for child in node.get_children():
		if child is Camera2D:
			return child
		var result = find_camera_in_node(child)
		if result:
			return result
	return null

func find_camera_recursive(node: Node) -> Camera2D:
	if node is Camera2D:
		return node
	
	for child in node.get_children():
		var result = find_camera_recursive(child)
		if result:
			return result
	
	return null

func follow_camera_position():
	if not camera:
		return
	
	# Get viewport size to calculate visible area
	var viewport_size = get_viewport_rect().size
	
	# Position on the RIGHT side of camera's view (middle height)
	# X: Right edge of screen minus offset
	# Y: Center of camera view
	global_position = camera.global_position + Vector2(viewport_size.x / 2 - x_offset_from_right, 0)
