extends Control
# Fishing Journal - Snufkin's collection book
# Book-style UI with page turning
# Full scene switch with state preservation (like map system)

var selected_fish_id: String = ""
var current_page: int = 0
var pages: Array = []  # Each page contains [left_rarity, right_rarity]

@onready var left_fish_list = $CenterContainer/BookContainer/MarginContainer/VBox/PageContent/LeftPage/ScrollContainer/FishList
@onready var right_fish_list = $CenterContainer/BookContainer/MarginContainer/VBox/PageContent/RightPage/ScrollContainer/FishList
@onready var left_page_title = $CenterContainer/BookContainer/MarginContainer/VBox/PageContent/LeftPage/PageTitle
@onready var right_page_title = $CenterContainer/BookContainer/MarginContainer/VBox/PageContent/RightPage/PageTitle
@onready var close_button = $CenterContainer/BookContainer/MarginContainer/VBox/TopBar/CloseButton
@onready var progress_label = $CenterContainer/BookContainer/MarginContainer/VBox/TopBar/ProgressLabel
@onready var prev_button = $CenterContainer/BookContainer/MarginContainer/VBox/BottomBar/PrevButton
@onready var next_button = $CenterContainer/BookContainer/MarginContainer/VBox/BottomBar/NextButton
@onready var page_label = $CenterContainer/BookContainer/MarginContainer/VBox/BottomBar/PageLabel
@onready var detail_panel = $DetailPanel
@onready var detail_name = $DetailPanel/MarginContainer/VBox/FishName
@onready var detail_description = $DetailPanel/MarginContainer/VBox/Description
@onready var detail_rarity = $DetailPanel/MarginContainer/VBox/RarityLabel
@onready var detail_stats = $DetailPanel/MarginContainer/VBox/StatsLabel
@onready var detail_hint = $DetailPanel/MarginContainer/VBox/HintLabel
@onready var detail_close = $DetailPanel/MarginContainer/VBox/CloseDetailButton

func _ready():
	# Normal process mode since we're a full scene (not overlay)
	process_mode = Node.PROCESS_MODE_INHERIT
	
	# Make fullscreen and centered
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_left = 0.0
	offset_top = 0.0
	offset_right = 0.0
	offset_bottom = 0.0
	
	# Ensure visible
	visible = true
	
	detail_panel.visible = false
	
	# Setup pages: each spread shows two rarities
	pages = [
		["common", "uncommon"],
		["rare", "legendary"]
	]
	
	# Connect close button (disconnect first to avoid duplicates)
	if close_button:
		if close_button.pressed.is_connected(_on_close_pressed):
			close_button.pressed.disconnect(_on_close_pressed)
		close_button.pressed.connect(_on_close_pressed)
		
		# Style close button with forest green theme
		var close_normal = StyleBoxFlat.new()
		close_normal.bg_color = Color(0.224, 0.369, 0.216)
		close_normal.corner_radius_top_left = 8
		close_normal.corner_radius_top_right = 8
		close_normal.corner_radius_bottom_left = 8
		close_normal.corner_radius_bottom_right = 8
		close_normal.border_width_left = 2
		close_normal.border_width_top = 2
		close_normal.border_width_right = 2
		close_normal.border_width_bottom = 2
		close_normal.border_color = Color(0.165, 0.275, 0.157)
		
		var close_hover = StyleBoxFlat.new()
		close_hover.bg_color = Color(0.275, 0.447, 0.267)
		close_hover.corner_radius_top_left = 8
		close_hover.corner_radius_top_right = 8
		close_hover.corner_radius_bottom_left = 8
		close_hover.corner_radius_bottom_right = 8
		close_hover.border_width_left = 2
		close_hover.border_width_top = 2
		close_hover.border_width_right = 2
		close_hover.border_width_bottom = 2
		close_hover.border_color = Color(0.224, 0.369, 0.216)
		close_hover.shadow_size = 6
		close_hover.shadow_color = Color(0, 0, 0, 0.2)
		
		close_button.add_theme_stylebox_override("normal", close_normal)
		close_button.add_theme_stylebox_override("hover", close_hover)
		close_button.add_theme_stylebox_override("pressed", close_normal)
		close_button.add_theme_color_override("font_color", Color.WHITE)
		close_button.add_theme_font_size_override("font_size", 16)
	
	if prev_button:
		if prev_button.pressed.is_connected(_on_prev_page):
			prev_button.pressed.disconnect(_on_prev_page)
		prev_button.pressed.connect(_on_prev_page)
		_style_navigation_button(prev_button)
	
	if next_button:
		if next_button.pressed.is_connected(_on_next_page):
			next_button.pressed.disconnect(_on_next_page)
		next_button.pressed.connect(_on_next_page)
		_style_navigation_button(next_button)
	
	if detail_close:
		if detail_close.pressed.is_connected(_on_detail_close_pressed):
			detail_close.pressed.disconnect(_on_detail_close_pressed)
		detail_close.pressed.connect(_on_detail_close_pressed)
		_style_navigation_button(detail_close)  # Use same styling as nav buttons
	
	populate_journal()
	update_progress()
	update_page_display()

func _input(event: InputEvent) -> void:
	# Close with ESC or J key (like map closes with ESC)
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("open_journal"):
		return_to_previous_scene()
		if get_viewport():
			get_viewport().set_input_as_handled()

func populate_journal():
	update_page_display()

func update_page_display():
	# Clear existing fish
	for child in left_fish_list.get_children():
		child.queue_free()
	for child in right_fish_list.get_children():
		child.queue_free()
	
	if current_page < 0 or current_page >= pages.size():
		return
	
	var page_data = pages[current_page]
	var left_rarity = page_data[0]
	var right_rarity = page_data[1]
	
	# Update titles with enhanced styling
	left_page_title.text = "✦ " + left_rarity.capitalize() + " Fish"
	left_page_title.add_theme_font_size_override("font_size", 20)
	left_page_title.add_theme_color_override("font_color", get_rarity_color(left_rarity))
	
	right_page_title.text = "✦ " + right_rarity.capitalize() + " Fish"
	right_page_title.add_theme_font_size_override("font_size", 20)
	right_page_title.add_theme_color_override("font_color", get_rarity_color(right_rarity))
	
	# Get fish for each page
	var left_fish = FishingData.get_fish_by_rarity(left_rarity)
	var right_fish = FishingData.get_fish_by_rarity(right_rarity)
	
	# Populate left page
	for fish_data in left_fish:
		create_fish_entry(fish_data, left_fish_list)
	
	# Populate right page
	for fish_data in right_fish:
		create_fish_entry(fish_data, right_fish_list)
	
	# Update page controls with enhanced styling
	page_label.text = "📄 Page %d of %d" % [current_page + 1, pages.size()]
	page_label.add_theme_font_size_override("font_size", 14)
	page_label.add_theme_color_override("font_color", Color(0.3, 0.3, 0.28))
	prev_button.disabled = (current_page == 0)
	next_button.disabled = (current_page >= pages.size() - 1)

func create_fish_entry(fish_data: Dictionary, parent_list: VBoxContainer):
	"""Create a single fish entry in the journal with enhanced information"""
	var fish_id = fish_data.get("id", "")
	var is_discovered = FishingData.has_discovered(fish_id)
	var rarity = fish_data.get("rarity", "common")
	
	var entry = PanelContainer.new()
	entry.custom_minimum_size = Vector2(0, 100)
	
	# Style with forest green theme matching main menu
	var style_box = StyleBoxFlat.new()
	if is_discovered:
		# Soft cream background with subtle green tint
		style_box.bg_color = Color(0.95, 0.97, 0.94, 1.0)
	else:
		# Muted, desaturated for undiscovered
		style_box.bg_color = Color(0.88, 0.90, 0.87, 0.6)
	
	# Elegant borders matching dialogue system
	style_box.border_width_left = 2
	style_box.border_width_top = 2
	style_box.border_width_right = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(0.224, 0.369, 0.216, 0.7)  # Forest green from main menu
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	
	# Subtle shadow for discovered fish
	if is_discovered:
		style_box.shadow_size = 3
		style_box.shadow_color = Color(0, 0, 0, 0.15)
	entry.add_theme_stylebox_override("panel", style_box)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	entry.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	margin.add_child(hbox)
	
	# Fish icon with rarity-colored background
	var icon_container = PanelContainer.new()
	var icon_style = StyleBoxFlat.new()
	if is_discovered:
		icon_style.bg_color = get_rarity_color(rarity).lightened(0.7)
		icon_style.border_width_left = 2
		icon_style.border_width_top = 2
		icon_style.border_width_right = 2
		icon_style.border_width_bottom = 2
		icon_style.border_color = get_rarity_color(rarity)
	else:
		icon_style.bg_color = Color(0.7, 0.7, 0.7, 0.3)
		icon_style.border_width_left = 2
		icon_style.border_width_top = 2
		icon_style.border_width_right = 2
		icon_style.border_width_bottom = 2
		icon_style.border_color = Color(0.5, 0.5, 0.5, 0.5)
	icon_style.corner_radius_top_left = 6
	icon_style.corner_radius_top_right = 6
	icon_style.corner_radius_bottom_left = 6
	icon_style.corner_radius_bottom_right = 6
	icon_container.add_theme_stylebox_override("panel", icon_style)
	icon_container.custom_minimum_size = Vector2(60, 60)
	hbox.add_child(icon_container)
	
	var icon_label = Label.new()
	icon_label.text = "🐟" if is_discovered else "?"
	icon_label.add_theme_font_size_override("font_size", 32)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	icon_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if not is_discovered:
		icon_label.modulate = Color(0.5, 0.5, 0.5, 0.6)
	icon_container.add_child(icon_label)
	
	# Fish info with better hierarchy
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)
	
	# Top row: Name + Rarity badge
	var top_row = HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 8)
	vbox.add_child(top_row)
	
	# Fish name with better typography
	var name_label = Label.new()
	name_label.text = fish_data.get("name", "Unknown") if is_discovered else "???"
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color(0.15, 0.25, 0.14) if is_discovered else Color(0.4, 0.4, 0.4))
	top_row.add_child(name_label)
	
	# Rarity badge
	if is_discovered:
		var rarity_badge = PanelContainer.new()
		var badge_style = StyleBoxFlat.new()
		badge_style.bg_color = get_rarity_color(rarity)
		badge_style.corner_radius_top_left = 4
		badge_style.corner_radius_top_right = 4
		badge_style.corner_radius_bottom_left = 4
		badge_style.corner_radius_bottom_right = 4
		badge_style.content_margin_left = 8
		badge_style.content_margin_right = 8
		badge_style.content_margin_top = 2
		badge_style.content_margin_bottom = 2
		rarity_badge.add_theme_stylebox_override("panel", badge_style)
		
		var rarity_label = Label.new()
		rarity_label.text = rarity.capitalize()
		rarity_label.add_theme_font_size_override("font_size", 11)
		rarity_label.add_theme_color_override("font_color", Color.WHITE)
		rarity_badge.add_child(rarity_label)
		top_row.add_child(rarity_badge)
	
	# Catch statistics with icons
	if is_discovered:
		var stats_row = HBoxContainer.new()
		stats_row.add_theme_constant_override("separation", 12)
		vbox.add_child(stats_row)
		
		var count = FishingData.caught_fish.get(fish_id, {}).get("total_count", 0)
		var count_label = Label.new()
		count_label.text = "⚓ Caught: " + str(count) + "x"
		count_label.add_theme_font_size_override("font_size", 12)
		count_label.add_theme_color_override("font_color", Color(0.3, 0.5, 0.28))
		stats_row.add_child(count_label)
		
		# Size indicator
		var size_range = fish_data.get("size_range", [0.3, 0.5])
		var avg_size = (size_range[0] + size_range[1]) / 2.0
		var size_label = Label.new()
		var size_text = "Small" if avg_size < 0.4 else ("Medium" if avg_size < 0.6 else "Large")
		size_label.text = "📏 " + size_text
		size_label.add_theme_font_size_override("font_size", 12)
		size_label.add_theme_color_override("font_color", Color(0.3, 0.5, 0.28))
		stats_row.add_child(size_label)
	
	# Location hint preview
	if is_discovered:
		var location_label = Label.new()
		location_label.text = "📍 " + fish_data.get("location_hint", "Unknown waters")
		location_label.add_theme_font_size_override("font_size", 11)
		location_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.38))
		location_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		vbox.add_child(location_label)
	else:
		var hint_label = Label.new()
		hint_label.text = "🔒 Not yet discovered"
		hint_label.add_theme_font_size_override("font_size", 12)
		hint_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		vbox.add_child(hint_label)
	
	# View details button with forest green styling
	if is_discovered:
		var button = Button.new()
		button.text = "Details"
		button.custom_minimum_size = Vector2(85, 36)
		
		# Style button like main menu
		var btn_normal = StyleBoxFlat.new()
		btn_normal.bg_color = Color(0.224, 0.369, 0.216)
		btn_normal.corner_radius_top_left = 6
		btn_normal.corner_radius_top_right = 6
		btn_normal.corner_radius_bottom_left = 6
		btn_normal.corner_radius_bottom_right = 6
		btn_normal.border_width_left = 2
		btn_normal.border_width_top = 2
		btn_normal.border_width_right = 2
		btn_normal.border_width_bottom = 2
		btn_normal.border_color = Color(0.165, 0.275, 0.157)
		
		var btn_hover = StyleBoxFlat.new()
		btn_hover.bg_color = Color(0.275, 0.447, 0.267)
		btn_hover.corner_radius_top_left = 6
		btn_hover.corner_radius_top_right = 6
		btn_hover.corner_radius_bottom_left = 6
		btn_hover.corner_radius_bottom_right = 6
		btn_hover.border_width_left = 2
		btn_hover.border_width_top = 2
		btn_hover.border_width_right = 2
		btn_hover.border_width_bottom = 2
		btn_hover.border_color = Color(0.224, 0.369, 0.216)
		btn_hover.shadow_size = 4
		btn_hover.shadow_color = Color(0, 0, 0, 0.2)
		
		button.add_theme_stylebox_override("normal", btn_normal)
		button.add_theme_stylebox_override("hover", btn_hover)
		button.add_theme_stylebox_override("pressed", btn_normal)
		button.add_theme_color_override("font_color", Color.WHITE)
		button.add_theme_font_size_override("font_size", 13)
		
		button.pressed.connect(_on_fish_selected.bind(fish_id))
		hbox.add_child(button)
	
	parent_list.add_child(entry)

func _on_fish_selected(fish_id: String):
	show_fish_detail(fish_id)

func show_fish_detail(fish_id: String):
	selected_fish_id = fish_id
	var fish_data = FishingData.get_fish_data(fish_id)
	var caught_data = FishingData.caught_fish.get(fish_id, {})
	
	if fish_data.is_empty():
		return
	
	# Enhanced detail display with better formatting
	detail_name.text = "🐟 " + fish_data.get("name", "Unknown")
	detail_name.add_theme_font_size_override("font_size", 28)
	detail_name.add_theme_color_override("font_color", Color(0.15, 0.25, 0.14))
	
	# Poetic description
	detail_description.text = fish_data.get("description", "")
	detail_description.add_theme_font_size_override("font_size", 14)
	detail_description.add_theme_color_override("font_color", Color(0.3, 0.3, 0.28))
	detail_description.autowrap_mode = TextServer.AUTOWRAP_WORD
	
	# Rarity with styled badge look
	var rarity = fish_data.get("rarity", "common").capitalize()
	detail_rarity.text = "✦ Rarity: " + rarity
	detail_rarity.add_theme_font_size_override("font_size", 16)
	detail_rarity.add_theme_color_override("font_color", get_rarity_color(fish_data.get("rarity", "common")))
	
	# Comprehensive statistics
	var count = caught_data.get("total_count", 0)
	var first_caught = caught_data.get("first_caught", 0)
	var date_str = "Unknown"
	if first_caught > 0:
		var datetime = Time.get_datetime_dict_from_unix_time(first_caught)
		date_str = "%d/%d/%d" % [datetime.month, datetime.day, datetime.year]
	
	# Size information
	var size_range = fish_data.get("size_range", [0.3, 0.5])
	var avg_size = (size_range[0] + size_range[1]) / 2.0
	var size_desc = "Small (%.1f-%.1f)" % [size_range[0], size_range[1]]
	if avg_size >= 0.6:
		size_desc = "Large (%.1f-%.1f)" % [size_range[0], size_range[1]]
	elif avg_size >= 0.4:
		size_desc = "Medium (%.1f-%.1f)" % [size_range[0], size_range[1]]
	
	detail_stats.text = "⚓ Times Caught: %d\n📅 First Caught: %s\n📏 Size Range: %s\n🌊 Swim Speed: %.3f" % [
		count, date_str, size_desc, fish_data.get("swim_speed", 0.02)
	]
	detail_stats.add_theme_font_size_override("font_size", 13)
	detail_stats.add_theme_color_override("font_color", Color(0.3, 0.5, 0.28))
	
	# Location hint in italic style
	detail_hint.text = "📍 " + fish_data.get("location_hint", "Unknown waters")
	detail_hint.add_theme_font_size_override("font_size", 13)
	detail_hint.add_theme_color_override("font_color", Color(0.4, 0.4, 0.38))
	
	detail_panel.visible = true

func _on_detail_close_pressed():
	detail_panel.visible = false

func update_progress():
	var discovered = FishingData.get_species_count()
	var total = FishingData.get_total_species()
	var percentage = (float(discovered) / float(total)) * 100.0 if total > 0 else 0.0
	
	# Enhanced progress display with icons and color coding
	progress_label.text = "📖 Collection: %d/%d (%d%%)" % [discovered, total, int(percentage)]
	progress_label.add_theme_font_size_override("font_size", 16)
	
	# Color code based on completion
	if percentage >= 100:
		progress_label.add_theme_color_override("font_color", Color(0.85, 0.65, 0.13))  # Gold for complete
	elif percentage >= 75:
		progress_label.add_theme_color_override("font_color", Color(0.4, 0.5, 0.9))  # Blue for rare
	elif percentage >= 50:
		progress_label.add_theme_color_override("font_color", Color(0.224, 0.369, 0.216))  # Forest green
	else:
		progress_label.add_theme_color_override("font_color", Color(0.3, 0.3, 0.28))

func get_rarity_color(rarity: String) -> Color:
	match rarity:
		"common":
			return Color(0.6, 0.6, 0.6)  # Gray
		"uncommon":
			return Color(0.4, 0.7, 0.4)  # Green
		"rare":
			return Color(0.4, 0.5, 0.9)  # Blue
		"legendary":
			return Color(0.85, 0.65, 0.13)  # Gold
		_:
			return Color.WHITE

func _on_close_pressed():
	# Return to previous scene (like map system)
	return_to_previous_scene()

func return_to_previous_scene():
	"""Return to the scene we came from (like map_controller pattern)"""
	print("[FishingJournal] Attempting to return. Previous scene: '", Global.previous_scene, "'")
	
	var scene_path = Global.previous_scene
	
	# Fallback to main scene if no previous scene saved
	if scene_path == "" or scene_path == null:
		push_warning("[FishingJournal] No previous scene saved! Returning to main scene as fallback.")
		scene_path = "res://scenes/main.tscn"
	
	print("[FishingJournal] Returning to: ", scene_path)
	
	# Clear journal state
	Global.previous_scene = ""
	Global.journal_is_open = false
	# Keep from_journal flag true so spawner doesn't create new fish
	# Keep saved_player_position for character restoration
	
	# Change scene
	var result = get_tree().change_scene_to_file(scene_path)
	if result != OK:
		push_error("[FishingJournal] Failed to change scene to: ", scene_path)
		# Last resort: try main menu
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_prev_page():
	if current_page > 0:
		current_page -= 1
		update_page_display()

func _on_next_page():
	if current_page < pages.size() - 1:
		current_page += 1
		update_page_display()

func _style_navigation_button(button: Button):
	"""Apply forest green styling to navigation buttons"""
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = Color(0.224, 0.369, 0.216)
	btn_normal.corner_radius_top_left = 6
	btn_normal.corner_radius_top_right = 6
	btn_normal.corner_radius_bottom_left = 6
	btn_normal.corner_radius_bottom_right = 6
	btn_normal.border_width_left = 2
	btn_normal.border_width_top = 2
	btn_normal.border_width_right = 2
	btn_normal.border_width_bottom = 2
	btn_normal.border_color = Color(0.165, 0.275, 0.157)
	
	var btn_hover = StyleBoxFlat.new()
	btn_hover.bg_color = Color(0.275, 0.447, 0.267)
	btn_hover.corner_radius_top_left = 6
	btn_hover.corner_radius_top_right = 6
	btn_hover.corner_radius_bottom_left = 6
	btn_hover.corner_radius_bottom_right = 6
	btn_hover.border_width_left = 2
	btn_hover.border_width_top = 2
	btn_hover.border_width_right = 2
	btn_hover.border_width_bottom = 2
	btn_hover.border_color = Color(0.224, 0.369, 0.216)
	btn_hover.shadow_size = 4
	btn_hover.shadow_color = Color(0, 0, 0, 0.2)
	
	var btn_disabled = StyleBoxFlat.new()
	btn_disabled.bg_color = Color(0.6, 0.6, 0.6, 0.5)
	btn_disabled.corner_radius_top_left = 6
	btn_disabled.corner_radius_top_right = 6
	btn_disabled.corner_radius_bottom_left = 6
	btn_disabled.corner_radius_bottom_right = 6
	btn_disabled.border_width_left = 2
	btn_disabled.border_width_top = 2
	btn_disabled.border_width_right = 2
	btn_disabled.border_width_bottom = 2
	btn_disabled.border_color = Color(0.5, 0.5, 0.5, 0.5)
	
	button.add_theme_stylebox_override("normal", btn_normal)
	button.add_theme_stylebox_override("hover", btn_hover)
	button.add_theme_stylebox_override("pressed", btn_normal)
	button.add_theme_stylebox_override("disabled", btn_disabled)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", Color(0.7, 0.7, 0.7))
	button.add_theme_font_size_override("font_size", 14)
