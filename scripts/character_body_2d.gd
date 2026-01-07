extends CharacterBody2D

# Player constants
const SPEED = 700.0
const GRAVITY = 800.0
const JUMP_FORCE = -300.0

# References to components
@onready var animated_sprite = $AnimatedSprite2D
@onready var idle_timer = $IdleTimer  # Reference to the idle timer
@onready var audio_player = $AudioStreamPlayer  # Reference to the music player

const IDLE_TIME_LIMIT = 15.0  # Time before playing sit animation and music
var is_idle = false  # Track if the player is idle
var toggle_idle = false 
var last_idle = "idle"
var was_moving = false

# Load the music file
var music_track = preload("res://assets/sound/harmonica-solo-2728.mp3")

func _ready():
	await get_tree().process_frame  # Ensure everything loads
	
	# Check if we're in the house interior scene - if so, don't load saved position
	var current_scene = get_tree().current_scene.name
	if current_scene == "HouseInterior":
		print("🏠 Inside house - keeping default spawn position")
	else:
		var saved_pos = Global.get_saved_position()
		
		if saved_pos != Vector2.ZERO:  
			global_position = saved_pos  # ✅ Use global_position instead of position
			print("✅ Player Spawned at:", global_position)
		else:
			print("⚠ No saved position, spawning at default.")
	
	idle_timer.wait_time = IDLE_TIME_LIMIT
	idle_timer.one_shot = true  # Ensure it only triggers once
	idle_timer.start()

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * SPEED
	velocity.y += GRAVITY * delta

	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_FORCE
		reset_idle_timer()  # Reset idle timer on jump

	# Prevent overriding sitting animation
	if is_idle:
		return  

	if is_on_floor():
		if direction == 0:  # Player stopped moving
			if was_moving:  # Only pick an idle animation when stopping
				last_idle = "idle" if randi() % 2 == 0 else "smoking"

			if idle_timer.time_left == 0 and not is_idle:
				play_sit_animation()
			else:
				animated_sprite.play(last_idle)  # Play the selected idle animation

			animated_sprite.flip_h = false  # Ensure idle is not flipped
			was_moving = false  # Mark that we're now idle
		else:
			animated_sprite.play("run_right")
			animated_sprite.flip_h = direction < 0
			reset_idle_timer()
			was_moving = true  # Mark that we're moving
	else:
		animated_sprite.play("jump")
		reset_idle_timer()
		was_moving = true  # Mark that we're moving

	move_and_slide()

func reset_idle_timer():
	idle_timer.start()
	stop_music()
	is_idle = false  # Reset idle state when moving

func _on_IdleTimer_timeout():
	play_sit_animation()

func play_sit_animation():
	animated_sprite.play("sitting")
	await get_tree().process_frame  # Ensure animation updates
	is_idle = true  # Mark player as idle
	play_music()


func play_music():  
	audio_player.stop()
	await get_tree().process_frame  # Ensure previous playback is cleared
	audio_player.stream = music_track
	audio_player.play() 

func stop_music():
	if audio_player.playing:
		audio_player.stop()


func _on_idle_timer_timeout() -> void:
	pass # Replace with function body.
