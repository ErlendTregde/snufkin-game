extends Node2D

@export var fish_scene: PackedScene  # Assign fish.tscn in the Inspector

func _ready():
	start_spawning()

func spawn_fish():
	if fish_scene:
		var fish = fish_scene.instantiate()  # Create fish instance
		add_child(fish)  # Add fish to scene
		
		# Try to find PathFollow2D inside the Fish node
		var path_follow = fish.get_node("Path2D/PathFollow2D")  # Adjust path if needed
		if path_follow:
			path_follow.progress_ratio = randf()  # Move fish to a random start point
			print("✅ Fish Spawned & Moving!")
		else:
			print("⚠ PathFollow2D not found in Fish scene!")
	
	# Restart spawning with a new random interval
	start_spawning()

func start_spawning():
	var timer = Timer.new()
	var random_spawn_time = randf_range(5.0, 60.0)  # Random time between 5 sec and 60 sec
	timer.wait_time = random_spawn_time
	timer.one_shot = true
	timer.connect("timeout", spawn_fish)
	add_child(timer)
	timer.start()
	
	print("⏳ Next fish in:", random_spawn_time, "seconds")
