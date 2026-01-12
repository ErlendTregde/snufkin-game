extends Node2D

var is_cast = false  
var speed = 200  
var cast_depth = 300  
var reel_speed = 150  
var fight_reel_speed = 50  
var original_position  
var fish_caught = null  
var reeling = false  
var fish_start_y = null  # ✅ Initialize fish's starting Y position

var fish_resistance = 40  # Fish fights back downwards
var pull_strength = 100  # How strong the player can pull the fish upwards

@onready var sprite = $Sprite2D  
@onready var area = $Area2D



func _ready():
	original_position = position  

func _process(delta):
	if reeling:
		# ✅ Fish always follows hook position
		update_fish_position()

		# ✅ Reeling controls
		if Input.is_action_pressed("catch_fish"):
			position.y -= pull_strength * delta  # Reel the fish upwards
		else:
			position.y += fish_resistance * delta  # Fish fights back

		# ✅ Move hook AND fish towards original position
		position.x = move_toward(position.x, original_position.x, speed * delta)

		# ✅ If the hook reaches the fishing pole, the fight ends
		# Allow a small margin so the bar can reach 100%
		if position.y <= original_position.y + 5:
			finish_reeling()
		return  # ✅ Disable normal movement when reeling

	# ✅ Normal movement when not reeling
	if is_cast:
		if Input.is_action_pressed("ui_left"):
			position.x -= speed * delta
		elif Input.is_action_pressed("ui_right"):
			position.x += speed * delta

		if Input.is_action_pressed("ui_down"):
			position.y += reel_speed * delta  
		elif Input.is_action_pressed("ui_up"):
			position.y -= reel_speed * delta  

func cast_hook():
	if reeling:
		return  # ✅ Prevent casting while reeling in a fish
	
	if not is_cast:
		is_cast = true
		smooth_move(Vector2(position.x, original_position.y + cast_depth))  
	else:
		is_cast = false
		return_to_rod()

func return_to_rod():
	if fish_caught and is_instance_valid(fish_caught):
		print("🐟 Fish reeling in...")  
		reeling = true  # Start fight
	else:
		smooth_move(original_position)  # Fast return if no fish  

func finish_reeling():
	# ✅ When hook reaches original position, the fish is delivered
	print("🎉 Fish fully reeled in!")
	if fish_caught and is_instance_valid(fish_caught):
		fish_caught.queue_free()
		fish_caught = null
		
		# Trigger new fish spawn
		var fish_spawner = get_node_or_null("/root/FishingScene/FishingZone/FishSpawner")
		if fish_spawner:
			fish_spawner.spawn_fish()
		else:
			print("⚠️ FishSpawner not found!")

	reeling = false  # Stop fight
	is_cast = false  # Allow recasting
	smooth_move(original_position)

func update_fish_position():
	if fish_caught and is_instance_valid(fish_caught):
		# Position fish centered on hook, slightly above it
		# The fish's root Node2D position needs to align with the hook
		var fish_path_follow = fish_caught.get_node_or_null("Path2D/PathFollow2D")
		if fish_path_follow:
			# Offset to center the fish sprite on the hook
			fish_caught.global_position = global_position - fish_path_follow.position + Vector2(0, -30)
		else:
			fish_caught.global_position = global_position + Vector2(0, -30)

func smooth_move(target_position: Vector2):
	if not is_inside_tree():
		return  # ✅ Prevent moving if the object is deleted

	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_position, 0.5)


# Detect fish collision
func _on_area_2d_area_entered(other_area):
	if other_area.is_in_group("fish") and fish_caught == null:
		# Get the root Fish node (Area2D -> PathFollow2D -> Path2D -> Fish)
		fish_caught = other_area.get_parent().get_parent().get_parent()
		print("✅ Fish caught:", fish_caught.name)
		
		# Stop the fish from swimming
		if fish_caught.has_method("set"):
			fish_caught.is_caught = true
		
		reeling = true
		fish_start_y = position.y  # ✅ Store hook's Y position at catch time (local coordinates)
		print("🎯 Hook position at catch:", fish_start_y)
