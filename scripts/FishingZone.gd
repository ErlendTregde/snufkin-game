extends Node2D

@export var fish_scene: PackedScene

@onready var spawn_area: CollisionShape2D = $Area2D/CollisionShape2D

func _ready():
	if fish_scene:
		spawn_fish()

func spawn_fish():
	if not spawn_area or not spawn_area.shape:
		return

	var shape = spawn_area.shape
	if not (shape is RectangleShape2D):
		return

	var half_size = shape.size * 0.5
	var area_position = spawn_area.global_position

	var spawn_x = randf_range(area_position.x - half_size.x, area_position.x + half_size.x)
	var spawn_y = randf_range(area_position.y - half_size.y, area_position.y + half_size.y)

	var fish_instance = fish_scene.instantiate()
	fish_instance.global_position = Vector2(spawn_x, spawn_y)

	add_child(fish_instance)
