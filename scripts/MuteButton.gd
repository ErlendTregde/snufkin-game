extends Button

var is_muted: bool = false
@onready var volume_slider = $VolumeSlider

func _ready():
	text = "🔊"
	
	# Setup slider
	if volume_slider:
		volume_slider.visible = false
		volume_slider.min_value = 0.0
		volume_slider.max_value = 1.0
		volume_slider.step = 0.01
		volume_slider.value = 0.5  # Start at 50% volume
		volume_slider.value_changed.connect(_on_volume_changed)
		volume_slider.focus_mode = Control.FOCUS_NONE  # Prevent keyboard input
		volume_slider.mouse_exited.connect(_on_slider_mouse_exited)
	
	# Set initial volume to 50%
	var master_bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus_idx, linear_to_db(0.5))
	
	update_audio_state()

func _on_pressed():
	is_muted = !is_muted
	update_audio_state()

func update_audio_state():
	# Get the audio bus index (0 is usually the Master bus)
	var master_bus_idx = AudioServer.get_bus_index("Master")
	
	# Mute or unmute
	AudioServer.set_bus_mute(master_bus_idx, is_muted)
	
	# Update button text
	if is_muted:
		text = "🔇"
	else:
		text = "🔊"

func _on_mouse_entered():
	if volume_slider:
		volume_slider.visible = true

func _on_mouse_exited():
	check_hide_slider()

func _on_slider_mouse_exited():
	check_hide_slider()

func check_hide_slider():
	if volume_slider:
		# Small delay to check if mouse moved to slider or button
		await get_tree().create_timer(0.05).timeout
		if volume_slider:
			var mouse_pos = get_global_mouse_position()
			var over_button = get_global_rect().has_point(mouse_pos)
			var over_slider = volume_slider.get_global_rect().has_point(mouse_pos)
			
			if not over_button and not over_slider:
				volume_slider.visible = false

func _on_volume_changed(value: float):
	var master_bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus_idx, linear_to_db(value))
	
	# Update mute state based on volume
	if value == 0:
		is_muted = true
		text = "🔇"
	else:
		is_muted = false
		text = "🔊"

