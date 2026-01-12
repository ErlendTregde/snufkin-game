extends Control

@onready var reel_bar = $ReelStrengthBar
@onready var reel_indicator = $ReelIndicator  # ✅ Reference to ReelIndicator


func reset_reel_indicator():
	if reel_indicator:
		reel_indicator.play("idle")  # 🎣 Switch back to idle animation when not pressing


func _ready():
	# Hide the entire UI - no longer used
	visible = false

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
		return

	# Correctly calculate total reeling distance
	var total_distance = abs(fish_start_y - hook_start_y)
	var reeled_in = abs(current_y - fish_start_y)

	# Prevent division errors
	var progress = 0.0
	if total_distance > 1:
		progress = clamp(reeled_in / total_distance, 0.0, 1.0)

	# Update reel bar
	reel_bar.value = progress * reel_bar.max_value

func on_reel_pressed():
	if reel_indicator:
		reel_indicator.visible = true  # ✅ Make sure it's visible
		reel_indicator.play("reeling")  # 🎣 Play reeling animation
