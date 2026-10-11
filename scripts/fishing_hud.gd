extends Control
# Fishing HUD - Enhanced display with nature-themed aesthetics

@onready var session_label = $BottomLeft/SessionInfo
@onready var recent_catches = $BottomRight/RecentCatches/VBox
@onready var progress_bar = $Bottom/ProgressBar
@onready var notification_label = $Center/NotificationLabel

var notification_tween: Tween
var recent_catch_limit = 5

func _ready():
	notification_label.modulate.a = 0
	
	# Style notification label
	notification_label.add_theme_font_size_override("font_size", 24)
	
	# Connect to fishing signals
	FishingData.fish_caught.connect(_on_fish_caught)
	FishingData.new_species_discovered.connect(_on_new_species)
	FishingData.achievement_unlocked.connect(_on_achievement_unlocked)
	
	# Apply forest green styling to panels
	_style_session_panel()
	_style_recent_catches_panel()
	_style_progress_bar()
	
	update_session_info()
	update_progress_bar()

func _style_session_panel():
	"""Apply forest green theme to session info panel"""
	if session_label and session_label.get_parent():
		var panel = session_label.get_parent()
		if panel is PanelContainer:
			var style = StyleBoxFlat.new()
			style.bg_color = Color(0.95, 0.97, 0.94, 0.95)  # Soft cream with slight transparency
			style.border_width_left = 3
			style.border_width_top = 3
			style.border_width_right = 3
			style.border_width_bottom = 3
			style.border_color = Color(0.224, 0.369, 0.216, 0.8)  # Forest green
			style.corner_radius_top_left = 12
			style.corner_radius_top_right = 12
			style.corner_radius_bottom_left = 12
			style.corner_radius_bottom_right = 12
			style.shadow_size = 6
			style.shadow_color = Color(0, 0, 0, 0.3)
			style.content_margin_left = 20
			style.content_margin_right = 20
			style.content_margin_top = 16
			style.content_margin_bottom = 16
			panel.add_theme_stylebox_override("panel", style)
	
	# Style the label itself
	session_label.add_theme_font_size_override("font_size", 15)
	session_label.add_theme_color_override("font_color", Color(0.15, 0.25, 0.14))

func _style_recent_catches_panel():
	"""Apply forest green theme to recent catches panel"""
	if recent_catches and recent_catches.get_parent() and recent_catches.get_parent().get_parent():
		var panel = recent_catches.get_parent().get_parent()
		if panel is PanelContainer:
			var style = StyleBoxFlat.new()
			style.bg_color = Color(0.95, 0.97, 0.94, 0.95)
			style.border_width_left = 3
			style.border_width_top = 3
			style.border_width_right = 3
			style.border_width_bottom = 3
			style.border_color = Color(0.224, 0.369, 0.216, 0.8)
			style.corner_radius_top_left = 12
			style.corner_radius_top_right = 12
			style.corner_radius_bottom_left = 12
			style.corner_radius_bottom_right = 12
			style.shadow_size = 6
			style.shadow_color = Color(0, 0, 0, 0.3)
			style.content_margin_left = 16
			style.content_margin_right = 16
			style.content_margin_top = 12
			style.content_margin_bottom = 12
			panel.add_theme_stylebox_override("panel", style)

func _style_progress_bar():
	"""Apply forest green theme to progress bar"""
	if progress_bar:
		# Background (empty part)
		var bg_style = StyleBoxFlat.new()
		bg_style.bg_color = Color(0.88, 0.90, 0.87, 0.9)
		bg_style.border_width_left = 2
		bg_style.border_width_top = 2
		bg_style.border_width_right = 2
		bg_style.border_width_bottom = 2
		bg_style.border_color = Color(0.224, 0.369, 0.216, 0.6)
		bg_style.corner_radius_top_left = 8
		bg_style.corner_radius_top_right = 8
		bg_style.corner_radius_bottom_left = 8
		bg_style.corner_radius_bottom_right = 8
		progress_bar.add_theme_stylebox_override("background", bg_style)
		
		# Foreground (filled part) - gradient from green to gold
		var fg_style = StyleBoxFlat.new()
		fg_style.bg_color = Color(0.224, 0.369, 0.216)  # Forest green
		fg_style.corner_radius_top_left = 6
		fg_style.corner_radius_top_right = 6
		fg_style.corner_radius_bottom_left = 6
		fg_style.corner_radius_bottom_right = 6
		progress_bar.add_theme_stylebox_override("fill", fg_style)
		
		# Style the label
		var label = progress_bar.get_node_or_null("Label")
		if label:
			label.add_theme_font_size_override("font_size", 14)
			label.add_theme_color_override("font_color", Color.WHITE)

func update_session_info():
	var total = FishingData.total_fish_caught
	var species = FishingData.get_species_count()
	var inventory_count = FishingData.fish_inventory.size()
	var total_species = FishingData.get_total_species()
	
	# Enhanced display with icons and better formatting
	session_label.text = "⚓ Session Catches: %d\n🐠 Species Found: %d/%d\n📦 Inventory: %d fish" % [
		total, species, total_species, inventory_count
	]
	
	# Add encouraging text based on progress
	var progress_percent = (float(species) / float(total_species)) * 100.0 if total_species > 0 else 0.0
	if progress_percent >= 100:
		session_label.text += "\n\n✨ Collection Complete!"
	elif progress_percent >= 75:
		session_label.text += "\n\n🌟 Almost there!"
	elif progress_percent >= 50:
		session_label.text += "\n\n🎣 Good progress!"
	elif progress_percent >= 25:
		session_label.text += "\n\n🌊 Keep fishing!"

func update_progress_bar():
	var progress = FishingData.get_collection_progress()
	progress_bar.value = progress * 100
	
	var label = progress_bar.get_node_or_null("Label")
	if label:
		label.text = "📖 Collection: %d%%" % int(progress * 100)
		
		# Dynamic color based on progress (update fill color)
		var fg_style = StyleBoxFlat.new()
		if progress >= 1.0:
			fg_style.bg_color = Color(0.85, 0.65, 0.13)  # Gold for complete
		elif progress >= 0.75:
			fg_style.bg_color = Color(0.4, 0.5, 0.9)  # Blue for rare
		elif progress >= 0.5:
			fg_style.bg_color = Color(0.275, 0.447, 0.267)  # Light green
		else:
			fg_style.bg_color = Color(0.224, 0.369, 0.216)  # Forest green
		
		fg_style.corner_radius_top_left = 6
		fg_style.corner_radius_top_right = 6
		fg_style.corner_radius_bottom_left = 6
		fg_style.corner_radius_bottom_right = 6
		progress_bar.add_theme_stylebox_override("fill", fg_style)

func _on_fish_caught(fish_id: String, is_new: bool):
	var fish_data = FishingData.get_fish_data(fish_id)
	add_recent_catch(fish_data, is_new)
	update_session_info()
	update_progress_bar()
	
	# Show notification
	if is_new:
		show_notification("NEW! " + fish_data.get("name", "Unknown"), get_rarity_color(fish_data.get("rarity", "common")))
	else:
		show_notification(fish_data.get("name", "Unknown") + " caught!", Color.WHITE)

func _on_new_species(fish_id: String):
	var fish_data = FishingData.get_fish_data(fish_id)
	print("🎣 New species: ", fish_data.get("name", fish_id))

func _on_achievement_unlocked(achievement_id: String):
	var ach_data = FishingData.get_achievement_progress(achievement_id)
	show_notification("🏆 " + ach_data.get("name", "Achievement"), Color(1.0, 0.84, 0.0))

func add_recent_catch(fish_data: Dictionary, is_new: bool):
	# Remove oldest if at limit
	if recent_catches.get_child_count() >= recent_catch_limit:
		var oldest = recent_catches.get_child(0)
		oldest.queue_free()
	
	# Create styled catch entry with panel
	var entry_panel = PanelContainer.new()
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(1, 1, 1, 0.15) if not is_new else Color(1, 0.95, 0.7, 0.3)
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	
	var rarity = fish_data.get("rarity", "common")
	if is_new:
		panel_style.border_color = Color(0.85, 0.65, 0.13)  # Gold for new
	else:
		panel_style.border_color = get_rarity_color(rarity).darkened(0.3)
	
	panel_style.corner_radius_top_left = 6
	panel_style.corner_radius_top_right = 6
	panel_style.corner_radius_bottom_left = 6
	panel_style.corner_radius_bottom_right = 6
	panel_style.content_margin_left = 10
	panel_style.content_margin_right = 10
	panel_style.content_margin_top = 6
	panel_style.content_margin_bottom = 6
	
	if is_new:
		panel_style.shadow_size = 4
		panel_style.shadow_color = Color(0.85, 0.65, 0.13, 0.4)
	
	entry_panel.add_theme_stylebox_override("panel", panel_style)
	
	var entry = HBoxContainer.new()
	entry.add_theme_constant_override("separation", 10)
	entry_panel.add_child(entry)
	
	# Icon with rarity background
	var icon_container = PanelContainer.new()
	var icon_style = StyleBoxFlat.new()
	icon_style.bg_color = get_rarity_color(rarity).lightened(0.7)
	icon_style.border_width_left = 2
	icon_style.border_width_top = 2
	icon_style.border_width_right = 2
	icon_style.border_width_bottom = 2
	icon_style.border_color = get_rarity_color(rarity)
	icon_style.corner_radius_top_left = 4
	icon_style.corner_radius_top_right = 4
	icon_style.corner_radius_bottom_left = 4
	icon_style.corner_radius_bottom_right = 4
	icon_container.add_theme_stylebox_override("panel", icon_style)
	icon_container.custom_minimum_size = Vector2(32, 32)
	
	var icon = Label.new()
	icon.text = "🐟"
	icon.add_theme_font_size_override("font_size", 18)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	icon.size_flags_vertical = Control.SIZE_EXPAND_FILL
	icon_container.add_child(icon)
	entry.add_child(icon_container)
	
	# Info container
	var info_vbox = VBoxContainer.new()
	info_vbox.add_theme_constant_override("separation", 2)
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	entry.add_child(info_vbox)
	
	# Top row: Name + NEW badge
	var top_row = HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 6)
	info_vbox.add_child(top_row)
	
	# Name
	var name_label = Label.new()
	name_label.text = fish_data.get("name", "Unknown")
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", Color(0.15, 0.25, 0.14))
	top_row.add_child(name_label)
	
	# NEW badge
	if is_new:
		var new_badge = PanelContainer.new()
		var badge_style = StyleBoxFlat.new()
		badge_style.bg_color = Color(0.85, 0.65, 0.13)
		badge_style.corner_radius_top_left = 3
		badge_style.corner_radius_top_right = 3
		badge_style.corner_radius_bottom_left = 3
		badge_style.corner_radius_bottom_right = 3
		badge_style.content_margin_left = 6
		badge_style.content_margin_right = 6
		badge_style.content_margin_top = 1
		badge_style.content_margin_bottom = 1
		new_badge.add_theme_stylebox_override("panel", badge_style)
		
		var new_label = Label.new()
		new_label.text = "NEW!"
		new_label.add_theme_font_size_override("font_size", 10)
		new_label.add_theme_color_override("font_color", Color.WHITE)
		new_badge.add_child(new_label)
		top_row.add_child(new_badge)
	
	# Rarity label
	var rarity_label = Label.new()
	rarity_label.text = rarity.capitalize()
	rarity_label.add_theme_font_size_override("font_size", 11)
	rarity_label.add_theme_color_override("font_color", get_rarity_color(rarity))
	info_vbox.add_child(rarity_label)
	
	recent_catches.add_child(entry_panel)
	
	# Fade in animation with bounce
	entry_panel.modulate.a = 0
	entry_panel.scale = Vector2(0.8, 0.8)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(entry_panel, "modulate:a", 1.0, 0.4).set_ease(Tween.EASE_OUT)
	tween.tween_property(entry_panel, "scale", Vector2(1.0, 1.0), 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func show_notification(text: String, color: Color = Color.WHITE):
	# Enhanced notification with background
	notification_label.text = text
	
	# Create a styled background if it doesn't exist
	if not notification_label.get_parent() is PanelContainer:
		# Already set up in scene, just style the text
		notification_label.add_theme_color_override("font_color", color)
		notification_label.add_theme_font_size_override("font_size", 26)
	
	# Add outline for better visibility
	notification_label.add_theme_constant_override("outline_size", 8)
	notification_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	
	if notification_tween:
		notification_tween.kill()
	
	# Enhanced animation with scale
	notification_label.scale = Vector2(0.8, 0.8)
	notification_tween = create_tween()
	notification_tween.set_parallel(true)
	notification_tween.tween_property(notification_label, "modulate:a", 1.0, 0.3).set_ease(Tween.EASE_OUT)
	notification_tween.tween_property(notification_label, "scale", Vector2(1.0, 1.0), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	notification_tween.chain()
	notification_tween.tween_interval(2.5)
	notification_tween.set_parallel(true)
	notification_tween.tween_property(notification_label, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)
	notification_tween.tween_property(notification_label, "scale", Vector2(0.9, 0.9), 0.5).set_ease(Tween.EASE_IN)

func get_rarity_color(rarity: String) -> Color:
	match rarity:
		"common":
			return Color(0.6, 0.6, 0.6)  # Gray
		"uncommon":
			return Color(0.3, 0.7, 0.3)  # Green
		"rare":
			return Color(0.4, 0.5, 0.9)  # Blue
		"legendary":
			return Color(0.85, 0.65, 0.13)  # Gold
		_:
			return Color.WHITE
