extends Control

@onready var reel_bar = $ReelStrengthBar
@onready var reel_indicator = $ReelIndicator  # ✅ Reference to ReelIndicator


func reset_reel_indicator():
	if reel_indicator:
		reel_indicator.play("idle")  # 🎣 Switch back to idle animation when not pressing


func _ready():
	reel_indicator.visible = false  # 🚫 Hide it until we catch a fish
	reel_indicator.play("idle")  # Start with idle animation

func show_ui():
	visible = true
	reel_bar.visible = true  
	reel_bar.value = 0  # ✅ Start with an empty progress bar
	reel_indicator.visible = true  
	reel_indicator.stop()  
	reel_indicator.play("idle")  

func hide_ui():
	visible = false
	reel_indicator.stop()  # Reset animation

func update_reel_progress(current_y, hook_start_y, fish_start_y):
	# Ensure fish_start_y is correctly set
	if fish_start_y == null:
		print("⚠️ Fish start position not set!")
		return

	# Correctly calculate total reeling distance
	var total_distance = abs(fish_start_y - hook_start_y)  # Total reeling distance
	var reeling_progress = abs(fish_start_y - current_y)  # How much has been reeled in

	# Prevent division errors
	var progress = 0.0
	if total_distance > 1:  # Only update if the distance is significant
		progress = clamp(1.0 - (reeling_progress / total_distance), 0.0, 1.0)

	# Update reel bar
	reel_bar.value = progress * reel_bar.max_value

	# Debugging output
	print("DEBUG: Fish Start Y:", fish_start_y)
	print("DEBUG: Hook Start Y:", hook_start_y)
	print("DEBUG: Current Y:", current_y)
	print("DEBUG: Total Distance:", total_distance)
	print("DEBUG: Reeling Progress:", reeling_progress)
	print("DEBUG: Progress (0-1):", progress)
	print("DEBUG: Reel Bar Value:", reel_bar.value)

func on_reel_pressed():
	if reel_indicator:
		reel_indicator.visible = true  # ✅ Make sure it's visible
		reel_indicator.play("reeling")  # 🎣 Play reeling animation
