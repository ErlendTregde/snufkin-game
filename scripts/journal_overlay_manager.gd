extends Node
# Journal Overlay Manager - Autoload singleton for global journal access
# Handles pause state, transitions, and input from any scene

signal journal_opened
signal journal_closed

const JOURNAL_SCENE := preload("res://scenes/fishing_journal.tscn")

var canvas_layer: CanvasLayer = null
var journal_instance: Control = null
var is_open: bool = false
var can_toggle: bool = true

# Transition settings
const TRANSITION_DURATION := 0.3

func _ready() -> void:
	# Create persistent canvas layer for overlay
	canvas_layer = CanvasLayer.new()
	canvas_layer.name = "JournalOverlayLayer"
	canvas_layer.layer = 100  # Above everything
	add_child(canvas_layer)
	
	# Set to always process (even when game paused)
	process_mode = Node.PROCESS_MODE_ALWAYS
	canvas_layer.process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	# Toggle journal with J key
	if event.is_action_pressed("open_journal") and can_toggle:
		if is_open:
			close_journal()
		else:
			open_journal()
		get_viewport().set_input_as_handled()

func open_journal() -> void:
	if is_open or not can_toggle or not canvas_layer:
		return
	
	# Pause the game
	get_tree().paused = true
	is_open = true
	can_toggle = false
	
	# Instance journal
	journal_instance = JOURNAL_SCENE.instantiate()
	canvas_layer.add_child(journal_instance)
	
	# Connect close signal
	if journal_instance.has_signal("journal_closed"):
		journal_instance.journal_closed.connect(_on_journal_close_requested)
	
	# Play open transition
	await _play_open_transition()
	
	can_toggle = true
	journal_opened.emit()

func close_journal() -> void:
	if not is_open or not can_toggle:
		return
	
	can_toggle = false
	
	# Play close transition
	await _play_close_transition()
	
	# Remove journal
	if journal_instance:
		journal_instance.queue_free()
		journal_instance = null
	
	# Unpause the game
	get_tree().paused = false
	is_open = false
	can_toggle = true
	journal_closed.emit()

func _play_open_transition() -> void:
	if not journal_instance:
		return
	
	# Start invisible and scaled down
	journal_instance.modulate.a = 0.0
	journal_instance.scale = Vector2(0.85, 0.85)
	
	# Set pivot to center of screen for scaling
	await get_tree().process_frame  # Wait for size to be calculated
	var viewport_size = get_viewport().get_visible_rect().size
	journal_instance.pivot_offset = viewport_size / 2.0
	
	# Create tween
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	
	# Animate fade in and scale up
	tween.tween_property(journal_instance, "modulate:a", 1.0, TRANSITION_DURATION)
	tween.tween_property(journal_instance, "scale", Vector2.ONE, TRANSITION_DURATION)
	
	await tween.finished

func _play_close_transition() -> void:
	if not journal_instance:
		return
	
	# Create tween
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)
	
	# Animate fade out and scale down
	tween.tween_property(journal_instance, "modulate:a", 0.0, TRANSITION_DURATION)
	tween.tween_property(journal_instance, "scale", Vector2(0.85, 0.85), TRANSITION_DURATION)
	
	await tween.finished

func _on_journal_close_requested() -> void:
	close_journal()
