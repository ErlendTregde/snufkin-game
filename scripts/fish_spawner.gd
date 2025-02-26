extends Node2D

@export var fish_scene: PackedScene  # Assign fish.tscn in the Inspector
@export var spawn_time: float = 3.0  # Time between spawns

func _ready():
	print("✅ FishSpawner Ready!")  # Confirm the script runs
	if fish_scene == null:
		print("❌ ERROR: No Fish Scene Assigned!")
	else:
		print("🎣 Fish Scene Assigned:", fish_scene.resource_path)
	
	spawn_fish()  # Try spawning a fish
	start_spawning()  # Start the timer

func spawn_fish():
	print("🐟 Attempting to Spawn Fish...")  # Debugging print

	var fish = fish_scene.instantiate()  # Create fish instance
	if fish == null:
		print("❌ ERROR: Failed to Instantiate Fish!")
		return

	add_child(fish)  # Add fish to scene
	
	# Find PathFollow2D inside the Fish node
	var path_follow = fish.find_child("PathFollow2D", true, false)
	if path_follow:
		path_follow.progress_ratio = 0  # Start at top
		print("✅ Fish Spawned & Moving!")
	else:
		print("⚠️ WARNING: PathFollow2D not found in Fish scene!")

func start_spawning():
	var timer = Timer.new()
	timer.wait_time = spawn_time
	timer.autostart = true
	timer.timeout.connect(spawn_fish)
	add_child(timer)
