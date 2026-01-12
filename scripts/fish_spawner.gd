extends Node2D

@export var fish_scene: PackedScene  # Assign fish.tscn in the Inspector
@export var spawn_interval_min: float = 3.0  # Minimum time between spawns
@export var spawn_interval_max: float = 7.0  # Maximum time between spawns
@export var max_fish: int = 3  # Maximum number of fish at once
@export var min_spawn_height: float = -100.0  # Minimum Y position for spawning
@export var max_spawn_height: float = 100.0  # Maximum Y position for spawning

var spawn_timer: Timer  # Timer reference

func _ready():
	spawn_timer = Timer.new()
	spawn_timer.wait_time = randf_range(spawn_interval_min, spawn_interval_max)
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(spawn_fish)
	add_child(spawn_timer)
	
	# Spawn initial fish immediately so they're visible before fishing starts
	for i in range(2):  # Spawn 2 fish at start
		spawn_fish()

func spawn_fish():
	if not fish_scene:
		print("❌ Error: No fish scene assigned!")
		return
	
	# Don't spawn if we already have max fish
	if get_fish_count() >= max_fish:
		return
	
	var fish = fish_scene.instantiate()
	add_child(fish)
	fish.add_to_group("fishes")  # Add fish to group

	# Set random spawn height
	var spawn_y = randf_range(min_spawn_height, max_spawn_height)
	fish.position.y = spawn_y
	
	# Randomly choose direction (true = left-to-right, false = right-to-left)
	var move_right = randf() > 0.5
	
	# Set random size (0.3 to 0.5 of original, since original is already 0.5)
	var size_scale = randf_range(0.3, 0.5)
	fish.set_direction(move_right, size_scale)
	
	var path_follow = fish.get_node_or_null("Path2D/PathFollow2D")
	if path_follow:
		# Start at beginning of path
		path_follow.progress_ratio = 0.0
		print("✅ Fish Spawned at height:", spawn_y, "Direction:", "Right" if move_right else "Left", "Size:", size_scale, "🐟 Total Fish:", get_fish_count())
	else:
		print("⚠ PathFollow2D not found in spawned fish! Children:")
		for child in fish.get_children():
			print("  - ", child.name)
	
	# Set next spawn timer to random interval
	spawn_timer.wait_time = randf_range(spawn_interval_min, spawn_interval_max)

func get_fish_count():
	# Count only valid fish nodes in the scene
	var fish_count = 0
	for fish in get_tree().get_nodes_in_group("fishes"):
		if is_instance_valid(fish):
			fish_count += 1
	return fish_count
