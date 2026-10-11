extends Node

var from_scene = ""  # Tracks which scene we're coming from ("house_interior", "fishing_scene", etc.)
var current_location = "tent"  # Tracks where the player currently is on the map (tent, moomin_house, bridge)
var previous_scene = ""  # Tracks which scene to return to after closing map
var saved_player_position = Vector2.ZERO  # Saves player position before opening map
var saved_position_scene = ""  # Which scene the saved position belongs to

# Journal state - reuse same position saving system
var journal_is_open = false  # Track if journal is currently open
var from_journal = false  # Flag to indicate we're returning from journal

# Fishing session state preservation (for journal trips)
var fishing_session_active = false  # Is there an active fishing session to restore
var fishing_session_catches = 0  # Number of catches in current session
var preserved_fish_data: Array = []  # Store active fish [{id, position, direction, scale}, ...]
