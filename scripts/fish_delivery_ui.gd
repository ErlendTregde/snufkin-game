extends Control
# Fish Delivery UI - Gift fish to NPCs
# Integrated with dialogue system using Moomin aesthetic

signal fish_delivered(fish_id: String, npc_name: String)
signal delivery_closed

@onready var fish_list = $Panel/MarginContainer/VBox/ScrollContainer/FishList
@onready var close_button = $Panel/MarginContainer/VBox/TopBar/CloseButton
@onready var title_label = $Panel/MarginContainer/VBox/TopBar/TitleLabel
@onready var npc_label = $Panel/MarginContainer/VBox/NPCLabel
@onready var empty_label = $Panel/MarginContainer/VBox/EmptyLabel

var current_npc_name: String = ""
var npc_preferences: Dictionary = {
	"Moomin mama": {
		"preferred_rarity": ["common", "uncommon"],
		"favorite_ids": ["silver_perch", "pond_roach"],
		"dialogue_happy": "Oh, what a lovely fish! This will make a wonderful meal for the family.",
		"dialogue_love": "My dear Snufkin! This is exactly what I needed for tonight's soup!",
		"dialogue_rare": "Such a beautiful creature! I'll treasure this gift."
	},
	"Moomintroll": {
		"preferred_rarity": ["uncommon", "rare"],
		"favorite_ids": ["rainbow_trout", "moon_fish", "story_fish"],
		"dialogue_happy": "Wow! I've never seen a fish like this before!",
		"dialogue_love": "This is amazing, Snufkin! Wait until I tell Snorkmaiden!",
		"dialogue_rare": "A legendary fish?! This will be the best story ever!"
	},
	"Little My": {
		"preferred_rarity": ["rare", "legendary"],
		"favorite_ids": ["northern_pike", "hattifattener_eel"],
		"dialogue_happy": "Hah! That's a fighter. I respect that.",
		"dialogue_love": "Now THAT'S what I'm talking about! A proper catch!",
		"dialogue_rare": "You caught THAT?! ...Impressive."
	},
	"Snorkmaiden": {
		"preferred_rarity": ["uncommon", "rare"],
		"favorite_ids": ["rainbow_trout", "golden_carp", "moon_fish"],
		"dialogue_happy": "Oh, how beautiful! The colors are so pretty!",
		"dialogue_love": "It's simply gorgeous! You're so thoughtful!",
		"dialogue_rare": "I've never seen anything so magical!"
	}
}

func _ready():
	# Set to work when paused (in case opened during pause)
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visible = false
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	if empty_label:
		empty_label.visible = false

func show_delivery_ui(npc_name: String):
	current_npc_name = npc_name
	if npc_label:
		npc_label.text = "Gift a fish to " + npc_name
	
	populate_fish_inventory()
	visible = true
	# Also pause the game when showing fish delivery
	get_tree().paused = true

func populate_fish_inventory():
	# Check if nodes exist
	if not fish_list or not empty_label:
		print("Warning: fish_delivery_ui nodes not found. Scene may not be properly set up.")
		return
	
	# Clear existing items
	for child in fish_list.get_children():
		child.queue_free()
	
	# Get player's fish inventory
	var inventory = FishingData.fish_inventory
	
	if inventory.is_empty():
		empty_label.text = "You have no fish to gift.\nGo fishing first!"
		empty_label.visible = true
		return
	
	empty_label.visible = false
	
	# Group fish by ID and count
	var fish_counts = {}
	for fish_id in inventory:
		if fish_counts.has(fish_id):
			fish_counts[fish_id] += 1
		else:
			fish_counts[fish_id] = 1
	
	# Create item for each unique fish
	for fish_id in fish_counts.keys():
		var fish_data = FishingData.get_fish_data(fish_id)
		if fish_data.is_empty():
			continue
		
		create_fish_item(fish_id, fish_data, fish_counts[fish_id])

func create_fish_item(fish_id: String, fish_data: Dictionary, count: int):
	var item = PanelContainer.new()
	
	# Style the item
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.95, 0.93, 0.88, 1.0)  # Cream/parchment
	style_box.border_width_left = 2
	style_box.border_width_top = 2
	style_box.border_width_right = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(0.55, 0.52, 0.45, 1.0)
	style_box.corner_radius_top_left = 6
	style_box.corner_radius_top_right = 6
	style_box.corner_radius_bottom_left = 6
	style_box.corner_radius_bottom_right = 6
	item.add_theme_stylebox_override("panel", style_box)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	item.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	margin.add_child(hbox)
	
	# Fish icon
	var icon = Label.new()
	icon.text = "🐟"
	icon.add_theme_font_size_override("font_size", 32)
	hbox.add_child(icon)
	
	# Fish info
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	hbox.add_child(vbox)
	
	var name_label = Label.new()
	name_label.text = fish_data.get("name", "Unknown")
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	vbox.add_child(name_label)
	
	var rarity_label = Label.new()
	rarity_label.text = fish_data.get("rarity", "common").capitalize()
	rarity_label.add_theme_font_size_override("font_size", 12)
	rarity_label.add_theme_color_override("font_color", get_rarity_color(fish_data.get("rarity", "common")))
	vbox.add_child(rarity_label)
	
	var count_label = Label.new()
	count_label.text = "Available: " + str(count)
	count_label.add_theme_font_size_override("font_size", 11)
	count_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	vbox.add_child(count_label)
	
	# Spacer
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)
	
	# Gift button
	var gift_button = Button.new()
	gift_button.text = "Gift"
	gift_button.custom_minimum_size = Vector2(80, 40)
	
	# Style button
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color(0.4, 0.7, 0.4, 1.0)  # Sage green
	button_style.corner_radius_top_left = 4
	button_style.corner_radius_top_right = 4
	button_style.corner_radius_bottom_left = 4
	button_style.corner_radius_bottom_right = 4
	gift_button.add_theme_stylebox_override("normal", button_style)
	
	gift_button.pressed.connect(_on_gift_pressed.bind(fish_id, fish_data))
	hbox.add_child(gift_button)
	
	if fish_list:
		fish_list.add_child(item)

func _on_gift_pressed(fish_id: String, fish_data: Dictionary):
	# Deliver the fish
	var success = FishingData.deliver_fish(fish_id, current_npc_name)
	
	if success:
		# Show reaction based on NPC preferences
		show_npc_reaction(fish_id, fish_data)
		
		# Emit signal
		emit_signal("fish_delivered", fish_id, current_npc_name)
		
		# Update display
		populate_fish_inventory()

func show_npc_reaction(fish_id: String, fish_data: Dictionary):
	var preferences = npc_preferences.get(current_npc_name, {})
	var rarity = fish_data.get("rarity", "common")
	var reaction_text = ""
	
	# Determine reaction level
	if preferences.get("favorite_ids", []).has(fish_id):
		reaction_text = preferences.get("dialogue_love", "Thank you so much!")
	elif rarity == "legendary" or rarity == "rare":
		reaction_text = preferences.get("dialogue_rare", "What a rare catch!")
	else:
		reaction_text = preferences.get("dialogue_happy", "Thank you!")
	
	# Show temporary notification
	print("💬 ", current_npc_name, ": ", reaction_text)
	# TODO: Show in-game dialogue bubble or notification

func _on_close_pressed():
	# Unpause the game
	get_tree().paused = false
	emit_signal("delivery_closed")
	visible = false

func get_rarity_color(rarity: String) -> Color:
	match rarity:
		"common":
			return Color(0.6, 0.6, 0.6)
		"uncommon":
			return Color(0.4, 0.7, 0.4)
		"rare":
			return Color(0.4, 0.5, 0.9)
		"legendary":
			return Color(0.85, 0.65, 0.13)
		_:
			return Color.WHITE
