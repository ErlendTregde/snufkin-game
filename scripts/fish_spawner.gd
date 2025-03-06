extends Node2D

@export var fish_scene: PackedScene  # Assign fish.tscn in the Inspector
@export var spawn_interval: float = 2.0  # Fish spawns every 2 seconds

var spawn_timer: Timer  # Timer reference

func _ready():
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(spawn_fish)
	add_child(spawn_timer)

func spawn_fish():
	if fish_scene:
		var fish = fish_scene.instantiate()
		add_child(fish)

		var path_follow = fish.get_node("Path2D/PathFollow2D")
		if path_follow:
			path_follow.progress_ratio = 0.0  # Start fish at the beginning of the path
			print("✅ Fish Spawned! 🐟 Total Fish:", get_fish_count())
		else:
			print("⚠ PathFollow2D not found in Fish scene!")

func get_fish_count():
	# Count only valid fish nodes in the scene
	var fish_count = 0
	for fish in get_tree().get_nodes_in_group("fishes"):
		if is_instance_valid(fish):
			fish_count += 1
	return fish_count
