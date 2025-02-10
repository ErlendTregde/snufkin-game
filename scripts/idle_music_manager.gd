extends Node

@onready var idle_timer = $IdleTimer  # Ensure correct IdleTimer is used
@onready var audio_player = $AudioStreamPlayer  # Audio player for music

const IDLE_TIME_LIMIT = 5.0  # Time before playing music

# Load the single music file
var music_track = preload("res://assets/sound/harmonica-solo-2728.mp3")

func _ready():
	print("IdleMusicManager is ready!")  
	idle_timer.wait_time = IDLE_TIME_LIMIT
	idle_timer.one_shot = false
	idle_timer.one_shot = true  # Ensure it only triggers once
	idle_timer.start()  # Start the idle timer

func reset_idle_timer():
	idle_timer.start()  # Reset idle timer
	stop_music()  # Stop music when resetting idle time

func _on_IdleTimer_timeout():
	print("Idle Timer Triggered! Playing sit animation.")
	get_parent().play_sit_animation()
	play_music()


func play_music():
	print("Playing Music...")  # Debugging output
	audio_player.stop()  # Stop any existing sound
	audio_player.stream = preload("res://assets/sound/harmonica-solo-2728.mp3")  # Assign file
	print("Assigned Stream:", audio_player.stream.resource_path)  # Confirm file assignment
	audio_player.play()
	print("Music Playing:", audio_player.playing)  # Check if actually playing


func stop_music():
	if audio_player.playing:
		audio_player.stop()  # Stop playing music when moving
