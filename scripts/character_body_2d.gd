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
	# Make player pausable
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
	await get_tree().process_frame  # Ensure everything loads
	
	# Check which scene we're in and spawn accordingly
	var current_scene = get_tree().current_scene.name
	var current_scene_path = get_tree().current_scene.scene_file_path
	print("[Player] Current scene: ", current_scene)
	print("[Player] Global.from_scene: '", Global.from_scene, "'")
	print("[Player] Saved position scene: '", Global.saved_position_scene, "'")
	
	if current_scene == "Main":
		# PRIORITY 1: Returning from map to SAME scene - restore exact position
		if Global.saved_player_position != Vector2.ZERO and Global.saved_position_scene == current_scene_path:
			print("[Player] Restoring saved position from map: ", Global.saved_player_position)
			global_position = Global.saved_player_position
			# Keep current_location as-is, LocationTracker will update if needed
			Global.saved_player_position = Vector2.ZERO
			Global.saved_position_scene = ""
			Global.from_scene = ""  # Clear from_scene
		# PRIORITY 2: Coming from different scene (house/fishing) - spawn at fixed points
		elif Global.from_scene == "house_interior":
			print("[Player] Spawning at Moomin house (from house)")
			global_position = Vector2(2588, 921)
			Global.current_location = "moomin_house"
			Global.from_scene = ""
			Global.saved_player_position = Vector2.ZERO
			Global.saved_position_scene = ""
		elif Global.from_scene == "fishing_scene":
			print("[Player] Spawning at bridge (from fishing)")
			global_position = Vector2(-1470, 1114)
			Global.current_location = "bridge"
			Global.from_scene = ""
			Global.saved_player_position = Vector2.ZERO
			Global.saved_position_scene = ""
		# PRIORITY 3: Coming from map to NEW location - spawn at fixed points
		elif Global.from_scene == "map_tent":
			print("[Player] Spawning at tent (from map selection)")
			global_position = Vector2(108, 1100)
			Global.current_location = "tent"
			Global.from_scene = ""
			Global.saved_player_position = Vector2.ZERO
			Global.saved_position_scene = ""
		elif Global.from_scene == "map_moomin":
			print("[Player] Spawning at Moomin house (from map selection)")
			global_position = Vector2(2588, 921)
			Global.current_location = "moomin_house"
			Global.from_scene = ""
			Global.saved_player_position = Vector2.ZERO
			Global.saved_position_scene = ""
		elif Global.from_scene == "map_bridge":
			print("[Player] Spawning at bridge (from map selection)")
			global_position = Vector2(-1470, 1114)
			Global.current_location = "bridge"
			Global.from_scene = ""
			Global.saved_player_position = Vector2.ZERO
			Global.saved_position_scene = ""
		else:
			# Default first spawn - keep whatever position is in the scene
			print("[Player] Using default spawn position: ", global_position)
			# Determine initial location based on spawn position
			if global_position.x < 1000:
				Global.current_location = "tent"
			elif global_position.x >= 2000 and global_position.x < 3000:
				Global.current_location = "moomin_house"
			elif global_position.x >= -2000 and global_position.x < -1000:
				Global.current_location = "bridge"
			else:
				Global.current_location = "tent"  # Default
			Global.saved_player_position = Vector2.ZERO
			Global.saved_position_scene = ""
	
	idle_timer.wait_time = IDLE_TIME_LIMIT
	idle_timer.one_shot = true
	idle_timer.start()

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * SPEED
	velocity.y += GRAVITY * delta

	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_FORCE
		reset_idle_timer()  # Reset idle timer on jump

	# Cancel sitting animation if moving left or right
	if is_idle and direction != 0:
		is_idle = false
		stop_music()
		reset_idle_timer()
	
	# Prevent overriding sitting animation if idle and not moving
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
