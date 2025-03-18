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
@onready var fishing_ui = get_node("/root/FishingScene/FishingUI/FishingUIControl")
@onready var reel_indicator = fishing_ui.get_node("ReelIndicator")  # ✅ Correct path



func _ready():
	original_position = position  

func _process(delta):
	if reeling:
		# ✅ Fish always follows hook position
		update_fish_position()
		
		# ✅ Update UI reel progress
		fishing_ui.update_reel_progress(
			position.y,        # Hook’s current Y position
			original_position.y,  # Hook’s starting Y position
			fish_start_y       # Fish’s starting Y position
		)

		# ✅ Reeling controls (button changes animation)
		if Input.is_action_pressed("catch_fish"):
			position.y -= pull_strength * delta  # Reel the fish upwards
			fishing_ui.on_reel_pressed()  # 🔥 Change sprite to reeling mode
		else:
			position.y += fish_resistance * delta  # Fish fights back
			fishing_ui.reset_reel_indicator()

		# ✅ Move hook AND fish towards original position
		position.x = move_toward(position.x, original_position.x, speed * delta)

		# ✅ If the hook reaches the fishing pole, the fight ends
		if position.y <= original_position.y:
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
		fishing_ui.show_ui()  # 🔥 Show fishing UI & play "idle" immediately  
		fishing_ui.reset_reel_indicator()  # ✅ Ensure idle animation starts at the beginning  
	else:
		smooth_move(original_position)  # Fast return if no fish  

func finish_reeling():
	# ✅ When hook reaches original position, the fish is delivered
	print("🎉 Fish fully reeled in!")
	if fish_caught and is_instance_valid(fish_caught):
		fish_caught.queue_free()
		fish_caught = null

	reeling = false  # Stop fight
	is_cast = false  # Allow recasting
	smooth_move(original_position)
	fishing_ui.hide_ui()  # 🔥 Hide UI after reeling ends

func update_fish_position():
	if fish_caught and is_instance_valid(fish_caught):
		# ✅ Fish exactly follows hook position
		fish_caught.global_position = global_position

func smooth_move(target_position: Vector2):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_position, 0.5)

func reset_reel_indicator():
	if reel_indicator:
		reel_indicator.play("idle")  # 🎣 Switch back to idle animation when not pressing


# Detect fish collision
func _on_area_2d_area_entered(other_area):
	if other_area.is_in_group("fish") and fish_caught == null:
		fish_caught = other_area.get_parent()
		print("✅ Fish caught:", fish_caught.name)
		reeling = true
		fish_start_y = fish_caught.global_position.y  # ✅ Store correct fish start position
		fishing_ui.show_ui()  # Show UI immediately
