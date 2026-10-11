extends Node2D

@export var fish_scene: PackedScene  # Assign fish.tscn in the Inspector
@export var spawn_interval_min: float = 3.0  # Minimum time between spawns
@export var spawn_interval_max: float = 7.0  # Maximum time between spawns
@export var max_fish: int = 3  # Maximum number of fish at once
@export var min_spawn_height: float = -100.0  # Minimum Y position for spawning
@export var max_spawn_height: float = 100.0  # Maximum Y position for spawning

var spawn_timer: Timer  # Timer reference
var active_fish_count: int = 0  # Cache fish count for performance
var initial_spawn_done: bool = false  # Track if we've done initial spawn

func _ready():
	spawn_timer = Timer.new()
	spawn_timer.wait_time = randf_range(spawn_interval_min, spawn_interval_max)
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(spawn_fish)
	add_child(spawn_timer)
	
	# Check if we're returning from journal with preserved fish
	if Global.from_journal and Global.fishing_session_active:
		print("[FishSpawner] Restoring preserved fishing session")
		restore_preserved_fish()
		Global.from_journal = false  # Clear flag after restoration
		Global.fishing_session_active = false  # Clear session flag
	else:
		# Normal start - spawn initial fish
		for i in range(2):  # Spawn 2 fish at start
			spawn_fish()
	
	initial_spawn_done = true

func restore_preserved_fish():
	"""Restore fish that were active before opening journal"""
	print("🔄 Restoring %d fish from preserved state" % Global.preserved_fish_data.size())
	
	for fish_data in Global.preserved_fish_data:
		if not fish_scene:
			continue
		
		# Get fish data from database by ID
		var db_fish_data = FishingData.get_fish_data(fish_data.get("id", ""))
		if db_fish_data.is_empty():
			db_fish_data = FishingData.get_random_fish_by_rarity()  # Fallback to random
		
		# Spawn fish
		var fish = fish_scene.instantiate()
		add_child(fish)
		fish.add_to_group("fishes")
		fish.tree_exited.connect(_on_fish_despawned)
		active_fish_count += 1
		
		# Restore fish properties
		if fish.has_method("set_fish_data"):
			fish.set_fish_data(db_fish_data)
		
		fish.global_position = fish_data.get("position", Vector2.ZERO)
		fish.scale = fish_data.get("scale", Vector2.ONE)
		
		var move_right = fish_data.get("move_right", true)
		var size_scale = fish.scale.x  # Use stored scale
		fish.set_direction(move_right, size_scale)
		
		print("  ✅ Restored: ", db_fish_data.get("name"), " at ", fish.global_position)
	
	# Clear preserved data after restoration
	Global.preserved_fish_data.clear()
	print("✅ Fish restoration complete")

func spawn_fish():
	if not fish_scene:
		return
	
	# Don't spawn if we already have max fish
	if active_fish_count >= max_fish:
		return
	
	# Get random fish from database based on rarity weights
	var fish_data = FishingData.get_random_fish_by_rarity()
	if fish_data.is_empty():
		print("⚠️ No fish data available")
		return
	
	var fish = fish_scene.instantiate()
	add_child(fish)
	fish.add_to_group("fishes")
	fish.tree_exited.connect(_on_fish_despawned)
	active_fish_count += 1
	
	# Set fish data from database
	if fish.has_method("set_fish_data"):
		fish.set_fish_data(fish_data)

	# Set random spawn height
	var spawn_y = randf_range(min_spawn_height, max_spawn_height)
	fish.position.y = spawn_y
	
	# Randomly choose direction (true = left-to-right, false = right-to-left)
	var move_right = randf() > 0.5
	
	# Use size from fish data
	var size_range = fish_data.get("size_range", [0.3, 0.5])
	var size_scale = randf_range(size_range[0], size_range[1])
	fish.set_direction(move_right, size_scale)
	
	var path_follow = fish.get_node_or_null("Path2D/PathFollow2D")
	if path_follow:
		path_follow.progress_ratio = 0.0
	
	# Set next spawn timer to random interval
	spawn_timer.wait_time = randf_range(spawn_interval_min, spawn_interval_max)
	
	# Debug info
	print("🎣 Spawned: ", fish_data.get("name"), " (", fish_data.get("rarity"), ")")

func _on_fish_despawned():
	active_fish_count -= 1

func get_fish_count():
	return active_fish_count
