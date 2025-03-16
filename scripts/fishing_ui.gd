extends Control

@onready var reel_bar = $ReelStrengthBar
@onready var reel_indicator = $ReelIndicator  # ✅ Reference to ReelIndicator

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



func update_reel_progress(current_y, fish_start_y, hook_end_y):
	# Ensure total_distance is correctly calculated
	var total_distance = abs(fish_start_y - hook_end_y)  # Total reeling distance
	var remaining_distance = abs(current_y - hook_end_y)  # How much is left to reel in

	# Declare progress outside the if-else block
	var progress = 0.0  # Default to 0

	# Prevent zero division errors and negative values
	if total_distance > 1:  # Use a small threshold to avoid issues with tiny values
		progress = clamp(1.0 - (remaining_distance / total_distance), 0.0, 1.0)

	# Ensure reel bar updates correctly
	reel_bar.value = progress * reel_bar.max_value

	# Debugging output
	print("DEBUG: Fish Start Y:", fish_start_y)
	print("DEBUG: Hook End Y:", hook_end_y)
	print("DEBUG: Current Y:", current_y)
	print("DEBUG: Total Distance:", total_distance)
	print("DEBUG: Remaining Distance:", remaining_distance)
	print("DEBUG: Progress (0-1):", progress)
	print("DEBUG: Reel Bar Value:", reel_bar.value)






func on_reel_pressed():
	reel_indicator.visible = true  # ✅ Force it to be visible
	reel_indicator.play("reeling")  # 🔥 Play reeling animation
	
func reset_reel_indicator():
	reel_indicator.play("idle")  # 🎣 Switch back to idle animation when not pressing
	
	
