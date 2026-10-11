extends Node
class_name FogManager

## Creates cinematic volumetric fog integrated with parallax layers
## Each fog layer is positioned to match specific parallax elements

@export_group("Fog Configuration")
## Base fog density
@export_range(0.0, 1.0) var base_density: float = 0.4

## Fog speed
@export var base_fog_speed: Vector2 = Vector2(0.015, 0.008)

@export_group("Atmospheric Depth")
## Far fog color (bluish/gray for distance)
@export var far_fog_color: Color = Color(0.5, 0.55, 0.68, 1.0)

## Mid fog color (neutral gray)
@export var mid_fog_color: Color = Color(0.7, 0.73, 0.78, 1.0)

## Near fog color (lighter for foreground)
@export var near_fog_color: Color = Color(0.85, 0.87, 0.9, 1.0)

## Foreground fog color (bright white for visibility over green)
@export var foreground_fog_color: Color = Color(0.95, 0.96, 0.98, 1.0)

## Ground fog density multiplier
@export_range(0.5, 3.0) var ground_fog_density: float = 1.6

@export_group("Auto-Mapping")
## Enable automatic position mapping from scene nodes
@export var auto_map_positions: bool = true

## Reference to ParallaxBackground node
var parallax_background: ParallaxBackground

## Reference to ParallaxForeground node (for foreground fog)
var parallax_foreground: ParallaxBackground

## Canvas layer for screen-space foreground fog
var fog_canvas_layer: CanvasLayer

var fog_layers: Array[FogLayer] = []


func _ready() -> void:
	# Find the ParallaxBackground nodes
	parallax_background = get_node("../ParallaxBackground")
	parallax_foreground = get_node("../ParallaxForeground")
	
	if not parallax_background:
		push_error("FogManager: ParallaxBackground node not found!")
		return
	
	if not parallax_foreground:
		push_error("FogManager: ParallaxForeground node not found!")
		return
	
	# Create CanvasLayer for screen-space foreground fog
	fog_canvas_layer = CanvasLayer.new()
	fog_canvas_layer.name = "ForegroundFogLayer"
	fog_canvas_layer.layer = 100  # High layer so it's in front
	get_parent().call_deferred("add_child", fog_canvas_layer)
	
	# Create fog layers deferred to avoid frame hitch
	_create_fog_deferred.call_deferred()


func _create_fog_deferred() -> void:
	# Create fog layers integrated with parallax structure
	if auto_map_positions:
		_create_auto_mapped_fog_layers()
	else:
		_create_integrated_fog_layers()


func _create_auto_mapped_fog_layers() -> void:
	# Automatically map fog positions from scene nodes
	var layer_configs = []
	
	# Query actual node positions
	var mountain_node = parallax_background.get_node_or_null("Mountan/Mountan")
	var forest_node = parallax_background.get_node_or_null("Forest/forest")
	var tree_node = parallax_background.get_node_or_null("Tree/tree")
	var ground_node = parallax_foreground.get_node_or_null("Ground/ground")
	
	# Extract positions and heights
	var mountain_y = 230.0
	var mountain_h = 512.0
	if mountain_node:
		mountain_y = mountain_node.offset_top
		mountain_h = mountain_node.offset_bottom - mountain_node.offset_top
	
	var forest_y = 398.0
	var forest_h = 542.0
	if forest_node:
		forest_y = forest_node.offset_top
		forest_h = forest_node.offset_bottom - forest_node.offset_top
	
	var tree_y = 699.0
	var tree_h = 540.0
	if tree_node:
		tree_y = tree_node.offset_top
		tree_h = tree_node.offset_bottom - tree_node.offset_top
	
	var ground_y = 940.0
	var ground_h = 642.0
	if ground_node:
		ground_y = ground_node.offset_top
		ground_h = ground_node.offset_bottom - ground_node.offset_top
	
	# Create fog configs based on actual positions
	layer_configs = [
		# Behind mountains
		["FogMountainBack", Vector2(0.05, 0.05), -1, mountain_y - 80.0, mountain_h + 100.0, far_fog_color, 0.65, 0.35, 0.25, 0.2, false],
		
		# At mountain level
		["FogMountainMid", Vector2(0.1, 0.1), 0, mountain_y - 30.0, mountain_h + 70.0, far_fog_color, 0.7, 0.5, 0.22, 0.18, false],
		
		# In front of mountains
		["FogMountainFront", Vector2(0.2, 0.2), 0, mountain_y + 70.0, mountain_h + 90.0, far_fog_color.lerp(mid_fog_color, 0.3), 0.55, 0.6, 0.2, 0.18, false],
		
		# Behind forest
		["FogForestBack", Vector2(0.3, 0.3), 0, forest_y - 50.0, forest_h + 80.0, far_fog_color.lerp(mid_fog_color, 0.5), 0.6, 0.7, 0.2, 0.18, false],
		
		# At forest level
		["FogForest", Vector2(0.4, 0.4), 1, forest_y - 20.0, forest_h + 30.0, mid_fog_color, 0.7, 0.8, 0.18, 0.16, false],
		
		# In front of forest
		["FogForestFront", Vector2(0.5, 0.5), 1, forest_y + 100.0, forest_h + 60.0, mid_fog_color.lerp(near_fog_color, 0.3), 0.55, 0.9, 0.18, 0.16, false],
		
		# Behind trees
		["FogTreeBack", Vector2(0.55, 0.55), 1, tree_y - 100.0, tree_h + 110.0, mid_fog_color.lerp(near_fog_color, 0.5), 0.6, 0.95, 0.16, 0.15, false],
		
		# At tree level
		["FogTree", Vector2(0.6, 0.6), 2, tree_y - 20.0, tree_h + 40.0, near_fog_color, 0.65, 1.0, 0.15, 0.14, false],
		
		# In front of trees - START CHUNKY STYLE
		["FogTreeFront", Vector2(0.7, 0.7), 3, tree_y + 50.0, tree_h - 40.0, foreground_fog_color, 0.7, 1.05, 0.15, 0.15, false, true],
		
		# FOREGROUND FOG - between trees and ground (BIG CHUNKY WISPS)
		["FogMidGround", Vector2(0.85, 0.85), 0, tree_y + 150.0, 450.0, foreground_fog_color, 0.85, 1.1, 0.18, 0.12, true, true],
		
		# Behind ground (CHUNKY)
		["FogGroundBack", Vector2(0.95, 0.95), 50, ground_y - 20.0, ground_h + 40.0, foreground_fog_color, 0.95, 1.13, 0.12, 0.15, true, true],
		
		# IN FRONT OF GROUND - most visible (BIG CHUNKY BLOBS)
		["FogGroundFront", Vector2(1.1, 1.1), 150, ground_y + 60.0, ground_h - 40.0, foreground_fog_color, 0.8, 1.2, 0.2, 0.2, true, true],
	]
	
	for config in layer_configs:
		var use_chunky = config[11] if config.size() > 11 else false
		_create_fog_at_depth(config[0], config[1], config[2], config[3], config[4], config[5], config[6], config[7], config[8], config[9], config[10], use_chunky)


func _create_integrated_fog_layers() -> void:
	# Define fog layers matching exact parallax structure with proper z-indices
	# Format: [name, motion_scale, z_index, vertical_offset, height, color, density_mult, speed_mult, top_fade, bottom_fade, use_foreground]
	# use_foreground: false = ParallaxBackground (layer -10), true = ParallaxForeground (layer 100)
	var fog_configs = [
		# BACKGROUND FOG (ParallaxBackground, layer -10)
		# Behind mountains (farthest back) - z_index -1
		["FogMountainBack", Vector2(0.05, 0.05), -1, 150.0, 600.0, far_fog_color, 0.65, 0.35, 0.25, 0.2, false],
		
		# At mountain level (z_index 0) - Mountains: Y=230, H=512
		["FogMountainMid", Vector2(0.1, 0.1), 0, 200.0, 580.0, far_fog_color, 0.7, 0.5, 0.22, 0.18, false],
		
		# In front of mountains, behind forest (z_index 0.5)
		["FogMountainFront", Vector2(0.2, 0.2), 0, 300.0, 600.0, far_fog_color.lerp(mid_fog_color, 0.3), 0.55, 0.6, 0.2, 0.18, false],
		
		# Behind forest (z_index 0.5)
		["FogForestBack", Vector2(0.3, 0.3), 0, 350.0, 620.0, far_fog_color.lerp(mid_fog_color, 0.5), 0.6, 0.7, 0.2, 0.18, false],
		
		# At forest level (z_index 1) - Forest: Y=398, H=542
		["FogForest", Vector2(0.4, 0.4), 1, 380.0, 570.0, mid_fog_color, 0.65, 0.8, 0.18, 0.16, false],
		
		# In front of forest, behind trees (z_index 1.5)
		["FogForestFront", Vector2(0.5, 0.5), 1, 500.0, 600.0, mid_fog_color.lerp(near_fog_color, 0.3), 0.5, 0.9, 0.18, 0.16, false],
		
		# Behind trees (z_index 1.5)
		["FogTreeBack", Vector2(0.55, 0.55), 1, 600.0, 650.0, mid_fog_color.lerp(near_fog_color, 0.5), 0.55, 0.95, 0.16, 0.15, false],
		
		# At tree level (z_index 2) - Trees: Y=699, H=540
		["FogTree", Vector2(0.6, 0.6), 2, 680.0, 580.0, near_fog_color, 0.6, 1.0, 0.15, 0.14, false],
		
		# IN FRONT OF TREES (z_index 3)
		["FogTreeFront", Vector2(0.7, 0.7), 3, 750.0, 500.0, near_fog_color, 0.45, 1.05, 0.15, 0.15, false],
		
		# FOREGROUND FOG (CHUNKY STYLE) - Fixed to screen with motion_scale 1.0
		# Between trees and ground (z_index 0 in foreground)
		["FogMidGround", Vector2(1.0, 1.0), 0, 0.0, 1080.0, foreground_fog_color, 0.85, 1.1, 0.05, 0.05, true, true],
		
		# Behind ground (z_index 50)
		["FogGroundBack", Vector2(1.0, 1.0), 50, 0.0, 1080.0, foreground_fog_color, 0.95, 1.13, 0.05, 0.05, true, true],
		
		# IN FRONT OF GROUND (z_index 150) - FRONT-MOST FOG (BIG CHUNKY BLOBS)
		["FogGroundFront", Vector2(1.0, 1.0), 150, 0.0, 1080.0, foreground_fog_color, 1.0, 1.2, 0.05, 0.05, true, true],
	]
	
	for config in fog_configs:
		var use_chunky = config[11] if config.size() > 11 else false
		_create_fog_at_depth(config[0], config[1], config[2], config[3], config[4], config[5], config[6], config[7], config[8], config[9], config[10], use_chunky)


func _create_fog_at_depth(
	fog_name: String,
	motion_scale: Vector2,
	z_index: int,
	vertical_offset: float,
	fog_height: float,
	fog_color: Color,
	density_multiplier: float,
	speed_multiplier: float,
	top_fade: float,
	bottom_fade: float,
	use_foreground: bool,
	use_chunky: bool = false
) -> void:
	# Create ParallaxLayer for this fog
	var fog_parallax_layer := ParallaxLayer.new()
	fog_parallax_layer.name = fog_name + "_ParallaxLayer"
	fog_parallax_layer.motion_scale = motion_scale
	fog_parallax_layer.z_index = z_index
	fog_parallax_layer.z_as_relative = true  # Use relative z-index within ParallaxBackground
	
	# Create FogLayer node
	var fog_layer := FogLayer.new()
	fog_layer.name = fog_name
	fog_layer.parallax_scale = motion_scale.x
	fog_layer.fog_color = fog_color
	fog_layer.fog_density = base_density * density_multiplier
	fog_layer.fog_speed = base_fog_speed * speed_multiplier
	fog_layer.ground_density = ground_fog_density
	fog_layer.vertical_offset = vertical_offset
	fog_layer.fog_height = fog_height
	fog_layer.top_fade = top_fade
	fog_layer.bottom_fade = bottom_fade
	fog_layer.use_chunky_style = use_chunky
	fog_layer.fog_z_index = z_index
	
	# Set chunk scale for chunky fog (bigger chunks closer to camera)
	if use_chunky:
		fog_layer.chunk_scale = remap(motion_scale.x, 0.7, 1.2, 0.6, 0.4)
	
	# Vary height falloff based on depth
	fog_layer.height_falloff = remap(motion_scale.x, 0.05, 1.2, 3.2, 1.0)
	
	# Vary turbulence based on depth (more turbulent in foreground)
	fog_layer.turbulence = remap(motion_scale.x, 0.05, 1.2, 0.3, 0.55)
	
	# Vary noise scale based on depth
	fog_layer.noise_scale = remap(motion_scale.x, 0.05, 1.2, 0.9, 1.8)
	
	# Add to appropriate container (deferred to avoid parent busy errors)
	if use_foreground:
		# Add to CanvasLayer for screen-fixed fog
		fog_canvas_layer.call_deferred("add_child", fog_layer)
	else:
		# Add fog layer to parallax layer
		fog_parallax_layer.call_deferred("add_child", fog_layer)
		# Add to ParallaxBackground for parallax fog
		parallax_background.call_deferred("add_child", fog_parallax_layer)
	
	fog_layers.append(fog_layer)


## Toggle fog visibility
func set_fog_enabled(enabled: bool) -> void:
	for fog_layer in fog_layers:
		fog_layer.visible = enabled


## Adjust overall fog intensity
func set_global_fog_intensity(multiplier: float) -> void:
	for fog_layer in fog_layers:
		fog_layer.set_fog_density(fog_layer.fog_density * multiplier)
