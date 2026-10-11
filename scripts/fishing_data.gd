extends Node
# Autoload singleton: FishingData
# Manages fish collection, achievements, and fishing statistics

signal fish_caught(fish_id: String, is_new: bool)
signal new_species_discovered(fish_id: String)
signal achievement_unlocked(achievement_id: String)
signal collection_milestone_reached(total_species: int)
signal fish_delivered(fish_id: String, npc_name: String)

# Fish database loaded from JSON
var fish_database: Dictionary = {}
var spawn_weights: Dictionary = {}

# Player's collection data
var caught_fish: Dictionary = {}  # fish_id -> { first_caught: timestamp, total_count: int }
var fish_inventory: Array = []  # Array of fish_id strings player currently has
var achievements: Dictionary = {}  # achievement_id -> { unlocked: bool, timestamp: timestamp }
var total_fish_caught: int = 0
var fishing_sessions: int = 0

# Achievement definitions
var achievement_definitions: Dictionary = {
	"moonlight_fisher": {
		"name": "Moonlight Fisher",
		"description": "Catch 5 fish during nighttime",
		"icon": "🌙",
		"condition": "night_catches",
		"target": 5,
		"progress": 0
	},
	"snufkin_melody": {
		"name": "Snufkin's Melody",
		"description": "Catch fish in all locations",
		"icon": "🎵",
		"condition": "all_locations",
		"target": 5,
		"progress": 0
	},
	"story_collector": {
		"name": "Story Collector",
		"description": "Discover 3 legendary fish",
		"icon": "📖",
		"condition": "legendary_count",
		"target": 3,
		"progress": 0
	},
	"patient_soul": {
		"name": "Patient Soul",
		"description": "Catch a rare fish after waiting patiently",
		"icon": "🍃",
		"condition": "patience_catch",
		"target": 1,
		"progress": 0
	},
	"river_wanderer": {
		"name": "River Wanderer",
		"description": "Fish in 5 different spots",
		"icon": "🌊",
		"condition": "unique_spots",
		"target": 5,
		"progress": 0
	},
	"tale_of_wonder": {
		"name": "Tale of Wonder",
		"description": "Catch all legendary fish",
		"icon": "✨",
		"condition": "all_legendary",
		"target": 3,
		"progress": 0
	},
	"first_catch": {
		"name": "First Catch",
		"description": "Catch your very first fish",
		"icon": "🎣",
		"condition": "total_caught",
		"target": 1,
		"progress": 0
	},
	"collection_starter": {
		"name": "Collection Starter",
		"description": "Discover 5 different species",
		"icon": "📚",
		"condition": "species_count",
		"target": 5,
		"progress": 0
	},
	"dedicated_angler": {
		"name": "Dedicated Angler",
		"description": "Discover 10 different species",
		"icon": "🏆",
		"condition": "species_count",
		"target": 10,
		"progress": 0
	}
}

# Stats for achievements
var night_catches: int = 0
var locations_fished: Dictionary = {}  # location_name -> bool
var unique_fishing_spots: int = 0
var patience_catches: int = 0

const SAVE_FILE = "user://fishing_data.save"

func _ready():
	load_fish_database()
	load_save_data()

func load_fish_database():
	var file_path = "res://data/fish_database.json"
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var data = json.data
			if data.has("fish_species"):
				for fish in data["fish_species"]:
					fish_database[fish["id"]] = fish
			if data.has("spawn_weights"):
				spawn_weights = data["spawn_weights"]
			print("✅ Fish database loaded: ", fish_database.size(), " species")
		else:
			push_error("❌ Failed to parse fish database JSON")
	else:
		push_error("❌ Fish database not found at: ", file_path)

func get_fish_data(fish_id: String) -> Dictionary:
	return fish_database.get(fish_id, {})

func get_all_fish() -> Array:
	return fish_database.values()

func get_fish_by_rarity(rarity: String) -> Array:
	var result = []
	for fish in fish_database.values():
		if fish.get("rarity") == rarity:
			result.append(fish)
	return result

func get_random_fish_by_rarity() -> Dictionary:
	# Weighted random selection based on rarity
	var total_weight = 0
	for weight in spawn_weights.values():
		total_weight += weight
	
	var random_value = randf() * total_weight
	var current_weight = 0
	var selected_rarity = "common"
	
	for rarity in spawn_weights.keys():
		current_weight += spawn_weights[rarity]
		if random_value <= current_weight:
			selected_rarity = rarity
			break
	
	# Get all fish of selected rarity
	var fish_list = get_fish_by_rarity(selected_rarity)
	if fish_list.size() > 0:
		return fish_list[randi() % fish_list.size()]
	
	# Fallback to first common fish
	return fish_database.values()[0] if fish_database.size() > 0 else {}

func register_catch(fish_id: String, is_night: bool = false, is_patient: bool = false):
	var is_new = not caught_fish.has(fish_id)
	
	# Update collection
	if is_new:
		caught_fish[fish_id] = {
			"first_caught": Time.get_unix_time_from_system(),
			"total_count": 1
		}
		emit_signal("new_species_discovered", fish_id)
	else:
		caught_fish[fish_id]["total_count"] += 1
	
	# Add to inventory
	fish_inventory.append(fish_id)
	total_fish_caught += 1
	
	# Update stats
	if is_night:
		night_catches += 1
	if is_patient:
		patience_catches += 1
	
	# Check achievements
	check_achievements(fish_id)
	
	emit_signal("fish_caught", fish_id, is_new)
	save_data()
	
	return is_new

func remove_from_inventory(fish_id: String) -> bool:
	var index = fish_inventory.find(fish_id)
	if index != -1:
		fish_inventory.remove_at(index)
		save_data()
		return true
	return false

func deliver_fish(fish_id: String, npc_name: String) -> bool:
	if remove_from_inventory(fish_id):
		emit_signal("fish_delivered", fish_id, npc_name)
		save_data()
		return true
	return false

func has_discovered(fish_id: String) -> bool:
	return caught_fish.has(fish_id)

func get_species_count() -> int:
	return caught_fish.size()

func get_total_species() -> int:
	return fish_database.size()

func get_collection_progress() -> float:
	if fish_database.size() == 0:
		return 0.0
	return float(caught_fish.size()) / float(fish_database.size())

func register_location(location_name: String):
	if not locations_fished.has(location_name):
		locations_fished[location_name] = true
		unique_fishing_spots += 1
		check_achievements("")

func check_achievements(fish_id: String = ""):
	var fish_data = get_fish_data(fish_id) if fish_id != "" else {}
	
	# Check each achievement
	for ach_id in achievement_definitions.keys():
		if achievements.get(ach_id, {}).get("unlocked", false):
			continue  # Already unlocked
		
		var ach = achievement_definitions[ach_id]
		var unlocked = false
		
		match ach["condition"]:
			"total_caught":
				ach["progress"] = total_fish_caught
				unlocked = total_fish_caught >= ach["target"]
			"species_count":
				ach["progress"] = get_species_count()
				unlocked = get_species_count() >= ach["target"]
			"night_catches":
				ach["progress"] = night_catches
				unlocked = night_catches >= ach["target"]
			"legendary_count":
				var legendary_count = 0
				for caught_id in caught_fish.keys():
					var fish = get_fish_data(caught_id)
					if fish.get("rarity") == "legendary":
						legendary_count += 1
				ach["progress"] = legendary_count
				unlocked = legendary_count >= ach["target"]
			"all_legendary":
				var all_legendary = get_fish_by_rarity("legendary")
				var caught_legendary = 0
				for fish in all_legendary:
					if has_discovered(fish["id"]):
						caught_legendary += 1
				ach["progress"] = caught_legendary
				unlocked = caught_legendary >= ach["target"]
			"unique_spots":
				ach["progress"] = unique_fishing_spots
				unlocked = unique_fishing_spots >= ach["target"]
			"all_locations":
				ach["progress"] = locations_fished.size()
				unlocked = locations_fished.size() >= ach["target"]
			"patience_catch":
				ach["progress"] = patience_catches
				unlocked = patience_catches >= ach["target"]
		
		if unlocked:
			unlock_achievement(ach_id)

func unlock_achievement(achievement_id: String):
	if not achievements.has(achievement_id):
		achievements[achievement_id] = {
			"unlocked": true,
			"timestamp": Time.get_unix_time_from_system()
		}
		emit_signal("achievement_unlocked", achievement_id)
		save_data()

func get_achievement_progress(achievement_id: String) -> Dictionary:
	var ach = achievement_definitions.get(achievement_id, {})
	var unlocked = achievements.get(achievement_id, {}).get("unlocked", false)
	return {
		"name": ach.get("name", ""),
		"description": ach.get("description", ""),
		"icon": ach.get("icon", ""),
		"progress": ach.get("progress", 0),
		"target": ach.get("target", 1),
		"unlocked": unlocked
	}

func get_all_achievements() -> Array:
	var result = []
	for ach_id in achievement_definitions.keys():
		var ach_data = get_achievement_progress(ach_id)
		ach_data["id"] = ach_id
		result.append(ach_data)
	return result

func save_data():
	var save_dict = {
		"caught_fish": caught_fish,
		"fish_inventory": fish_inventory,
		"achievements": achievements,
		"total_fish_caught": total_fish_caught,
		"fishing_sessions": fishing_sessions,
		"night_catches": night_catches,
		"locations_fished": locations_fished,
		"unique_fishing_spots": unique_fishing_spots,
		"patience_catches": patience_catches
	}
	
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_var(save_dict)
		file.close()

func load_save_data():
	if not FileAccess.file_exists(SAVE_FILE):
		return
	
	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	if file:
		var save_dict = file.get_var()
		file.close()
		
		if save_dict:
			caught_fish = save_dict.get("caught_fish", {})
			fish_inventory = save_dict.get("fish_inventory", [])
			achievements = save_dict.get("achievements", {})
			total_fish_caught = save_dict.get("total_fish_caught", 0)
			fishing_sessions = save_dict.get("fishing_sessions", 0)
			night_catches = save_dict.get("night_catches", 0)
			locations_fished = save_dict.get("locations_fished", {})
			unique_fishing_spots = save_dict.get("unique_fishing_spots", 0)
			patience_catches = save_dict.get("patience_catches", 0)
			
			print("✅ Fishing data loaded: ", caught_fish.size(), " species discovered")

func reset_all_data():
	caught_fish.clear()
	fish_inventory.clear()
	achievements.clear()
	total_fish_caught = 0
	fishing_sessions = 0
	night_catches = 0
	locations_fished.clear()
	unique_fishing_spots = 0
	patience_catches = 0
	save_data()
