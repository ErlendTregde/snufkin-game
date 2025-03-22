extends Node2D

@export var fish_scene: PackedScene  # ✅ Assign the fish scene in Inspector

@onready var spawn_area: CollisionShape2D = $Area2D/CollisionShape2D  # ✅ Get spawn area

func _ready():
	if not fish_scene:
		print("❌ Error: No fish scene assigned!")
		return
	spawn_fish()  # ✅ Spawn fish when entering the scene

func spawn_fish():
	if not spawn_area or not spawn_area.shape:
		print("❌ Error: spawn_area missing shape!")
		return

	# ✅ Ensure shape is a RectangleShape2D
	var shape = spawn_area.shape
	if !(shape is RectangleShape2D):
		print("❌ Error: spawn_area shape is not a RectangleShape2D!")
		return

	var half_size = shape.size * 0.5  # ✅ Get correct extents in Godot 4
	var area_position = spawn_area.global_position  # ✅ Use global position

	# ✅ Calculate random spawn position inside the area
	var spawn_x = randf_range(area_position.x - half_size.x, area_position.x + half_size.x)
	var spawn_y = randf_range(area_position.y - half_size.y, area_position.y + half_size.y)

	# ✅ Instantiate and position fish
	var fish_instance = fish_scene.instantiate()
	fish_instance.global_position = Vector2(spawn_x, spawn_y)

	# ✅ Add fish to FishingZone
	add_child(fish_instance)
	print("🐟 Fish spawned at:", fish_instance.global_position)
