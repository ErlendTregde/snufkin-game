extends Node2D

# Load the wind gust scene
@export var wind_gust_scene: PackedScene
@export var spawn_interval_min = 0.7
@export var spawn_interval_max = 3.5
@export var spawn_y_min = 700.0  # More height variation
@export var spawn_y_max = 1000.0  # Wider spawn range

var spawn_timer = 0.0
var next_spawn_time = 0.0

func _ready():
	randomize()
	next_spawn_time = randf_range(spawn_interval_min, spawn_interval_max)

func _process(delta):
	spawn_timer += delta
	
	if spawn_timer >= next_spawn_time:
		spawn_wind_gust()
		spawn_timer = 0.0
		next_spawn_time = randf_range(spawn_interval_min, spawn_interval_max)
	
	# Clean up old wind gusts that went off-screen (failsafe)
	cleanup_old_gusts()

func spawn_wind_gust():
	if wind_gust_scene == null:
		print("Wind gust scene not assigned!")
		return
	
	var wind_gust = wind_gust_scene.instantiate()
	
	# Get the camera and viewport
	var camera = get_viewport().get_camera_2d()
	if camera == null:
		return
		
	var viewport_size = get_viewport().get_visible_rect().size
	var camera_pos = camera.get_screen_center_position()
	
	# Path now starts at 2200 local, ends at -200 local (right to left)
	# Spawn so the path START (2200 local) is just off the right edge
	var right_edge = camera_pos.x + (viewport_size.x / 2.0)
	var spawn_x = right_edge - 2200  # So 2200 local starts at right edge
	var spawn_y = camera_pos.y + randf_range(-200, 100)  # Relative to camera center
	var spawn_pos = Vector2(spawn_x, spawn_y)
	
	wind_gust.position = spawn_pos
	
	# Set properties BEFORE adding to scene tree
	# Randomize some properties for variety
	var base_trail_length = randf_range(0.35, 0.65)
	var base_width = 9.0
	var base_trail_speed = randf_range(0.003, 0.006)
	
	wind_gust.random_y_offset = randf_range(20.0, 40.0)
	
	# Scale based on height - higher up (further from camera) = smaller and thinner AND slower
	var y_offset = spawn_y - camera_pos.y  # -200 to 100
	var scale_factor = remap(y_offset, -200, 100, 0.25, 1.0)  # 25% at top, 100% at bottom
	
	# Apply scaling to trail_length, width, and speed (parallax effect)
	wind_gust.trail_length = base_trail_length * scale_factor
	wind_gust.width = base_width * scale_factor
	wind_gust.trail_speed = base_trail_speed * scale_factor  # Slower when further back
	
	# Get the ParallaxBackground node to add wind at different depths
	var parallax_bg = get_node("../ParallaxBackground")
	
	if parallax_bg and randf() < 0.4:  # 40% spawn in parallax layers (between backgrounds)
		# Add directly to ParallaxBackground with z_index between layers
		# Mountan = z_index 0, Forest = z_index 1, Tree = z_index 2
		var depth_options = [0, 1, 1, 2, 2, 3, 3]  # At and slightly above each layer
		wind_gust.z_index = depth_options[randi() % depth_options.size()]
		parallax_bg.add_child(wind_gust)
	else:
		# 60% spawn in foreground (completely outside parallax, on top of everything)
		wind_gust.z_index = randi_range(5, 8)  # High z_index to be in front of all parallax
		add_child(wind_gust)  # Add to WindGustSpawner, NOT parallax

func cleanup_old_gusts():
	# Remove wind gusts that are too far off screen (failsafe in case queue_free fails)
	var camera = get_viewport().get_camera_2d()
	if camera == null:
		return
	
	var camera_pos = camera.get_screen_center_position()
	var viewport_size = get_viewport().get_visible_rect().size
	
	var total_gusts = 0
	
	# Check children of this spawner
	for child in get_children():
		if child.has_method("queue_free"):
			total_gusts += 1
			if child.global_position.x < camera_pos.x - viewport_size.x:
				child.queue_free()
	
	# Check children of ParallaxBackground
	var parallax_bg = get_node_or_null("../ParallaxBackground")
	if parallax_bg:
		for child in parallax_bg.get_children():
			if not child is ParallaxLayer and child.has_method("queue_free"):
				total_gusts += 1
				if child.global_position.x < camera_pos.x - viewport_size.x:
					child.queue_free()
	
	if total_gusts > 15:
		print("⚠️ HIGH WIND COUNT: ", total_gusts, " gusts on screen!")
