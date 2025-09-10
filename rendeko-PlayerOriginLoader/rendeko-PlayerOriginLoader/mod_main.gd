extends Node

const Config = preload("res://mods-unpacked/rendeko-PlayerOriginLoader/Config.gd")
const OriginRegistry = preload("res://mods-unpacked/rendeko-PlayerOriginLoader/OriginRegistry.gd")
const UIManager = preload("res://mods-unpacked/rendeko-PlayerOriginLoader/UIManager.gd")
const ModelManager = preload("res://mods-unpacked/rendeko-PlayerOriginLoader/ModelManager.gd")

var origin_registry
var ui_manager
var model_manager

func _init():
	ModLoaderLog.info("Initialized.", Config.MOD_NAME)

func _ready():
	origin_registry = OriginRegistry.new()
	ui_manager = UIManager.new()
	model_manager = ModelManager.new()
	
	add_child(origin_registry)
	add_child(ui_manager)
	add_child(model_manager)
	
	get_tree().connect("node_added", self, "_on_node_added")

# Register custom origin from zip mods
func register_custom_origin(origin_dict):
	return origin_registry.register_origin(origin_dict)

func _on_node_added(node):
	if node.filename == Config.PLAYER_STATS_SCENE:
		_handle_player_stats_node(node)
	elif node.filename == Config.PLAYER_INFANTRY_SCENE:
		_handle_player_infantry_node(node)

# Handle Player Stats node setup
func _handle_player_stats_node(node):
	if not ui_manager.validate_ui_nodes(node):
		return
	
	ui_manager.setup_ui_connections(node, self, "_on_item_selected", self, "_model_preview_handler")

# Handle Player Infantry node setup (only used for scaling atm)
func _handle_player_infantry_node(node):
	ModLoaderLog.debug("Setting up player infantry node for scaling", Config.MOD_NAME)
	
	var guy2_node = node.get_node_or_null("guy2")
	if guy2_node and not guy2_node.is_connected("tree_entered", self, "_apply_player_scaling"):
		if Dataset.player_stats.id != null:
			guy2_node.connect("tree_entered", self, "_apply_player_scaling", [node, Dataset.player_stats.id])
			ModLoaderLog.debug("Connected scaling signal for player infantry", Config.MOD_NAME)

# Apply player scaling when guy2 enters tree
func _apply_player_scaling(player_node, origin_id):
	ModLoaderLog.debug("Applying player scaling for origin: " + str(origin_id), Config.MOD_NAME)
	
	var player_infantry_node = player_node.get_node_or_null("Player_Infantry")
	if player_infantry_node:
		model_manager.apply_player_scale(player_infantry_node, origin_id, origin_registry)
	else:
		ModLoaderLog.warning("Could not find Player_Infantry node. Scaling player_node directly", Config.MOD_NAME)
		model_manager.apply_player_scale(player_node, origin_id, origin_registry)

# Handle model preview visibility changes
func _model_preview_handler(player_stats_node):
	ui_manager.detect_screen_type(player_stats_node)
	origin_registry.import_default_origins()
	_add_mod_origins_to_dataset(player_stats_node)
	ui_manager.refresh_origin_list(player_stats_node)
	
	origin_registry.build_itemlist_map()
	#ModLoaderLog.debug("Model preview handler processing complete", Config.MOD_NAME)
	
	# Apply current player origin if set
	if Dataset.player_stats.id != null:
		var skeleton_node = ui_manager.get_skeleton_node(player_stats_node)
		if skeleton_node:
			model_manager.replace_model(skeleton_node, Dataset.player_stats.id, origin_registry, ui_manager)

# Handle origin selection from ItemList
func _on_item_selected(item, player_stats_node):
	#ModLoaderLog.debug("Origin selected at index: " + str(item), Config.MOD_NAME)
	origin_registry.import_default_origins()
	var selected_origin_id = origin_registry.get_origin_id_from_itemlist_index(item)

	if selected_origin_id.empty():
		ModLoaderLog.warning("Selected origin has empty ID", Config.MOD_NAME)
		return
	
	var skeleton_node = ui_manager.get_skeleton_node(player_stats_node)
	if skeleton_node:
		model_manager.replace_model(skeleton_node, selected_origin_id, origin_registry, ui_manager)

# Add mod origins to Dataset.character_classes
func _add_mod_origins_to_dataset(player_stats_node):
	if origin_registry.is_empty():
		return
	
	var all_origins = origin_registry.get_all_origins()
	for origin_id in all_origins:
		var origin_data = all_origins[origin_id]
		var existing_index = origin_registry.find_origin_index_in_dataset(origin_id)
		
		if existing_index != -1:
			_add_single_origin_to_dataset(origin_id, true, existing_index, player_stats_node)
		else:
			_add_single_origin_to_dataset(origin_id, false, -1, player_stats_node)

# Import a single origin to Dataset.character_classes
func _add_single_origin_to_dataset(origin_id: String, exists: bool, existing_index: int, player_stats_node):
	var origin_data = origin_registry.get_origin(origin_id)
	if origin_data.empty():
		return
	
	# Create dataset origin
	var dataset_origin
	if exists and existing_index >= 0:
		dataset_origin = Dataset.character_classes[existing_index]
	else:
		dataset_origin = Dataset.Player.new()
	
	# Set basic properties
	dataset_origin.id = origin_data.get("id", "")
	dataset_origin.bodytype = origin_data.get("bodytype", Config.DEFAULT_MALE_BODY)
	dataset_origin.dna_damage = origin_data.get("dna_damage", 0)
	
	# Set materials
	_set_material_if_exists(dataset_origin, origin_data, "body_material")
	_set_material_if_exists(dataset_origin, origin_data, "face_material")
	
	# Only assign game data in new game screen (to not overwrite player stats/equipment)
	var is_new_game = ui_manager.is_new_game()
	if is_new_game:
		_assign_character_stats(dataset_origin, origin_data)
		_assign_weapons(dataset_origin, origin_data)
		_assign_equipment_parts(dataset_origin, origin_data)
	
	# Assign starting items
	if origin_data.has("starting_items"):
		dataset_origin.starting_items = origin_data["starting_items"]
	
	# Add to dataset if new
	if not exists:
		Dataset.character_classes.append(dataset_origin)
		ui_manager.refresh_origin_list(player_stats_node)

# Set material properties if they exist in origin data
func _set_material_if_exists(dataset_origin: Object, origin_dict: Dictionary, material_key: String):
	if origin_dict.has(material_key):
		var material = load(origin_dict[material_key])
		if material:
			dataset_origin.set(material_key, material)

# Assign character stats from origin data
func _assign_character_stats(dataset_origin: Object, origin_dict: Dictionary):
	for stat in Config.STAT_KEYS:
		if origin_dict.has(stat):
			dataset_origin.set(stat, origin_dict[stat])

# Assign weapons from origin data
func _assign_weapons(dataset_origin: Object, origin_dict: Dictionary):
	for weapon in Config.WEAPON_KEYS:
		if origin_dict.has(weapon):
			dataset_origin.set(weapon, get_by_id(Dataset.weapons, origin_dict[weapon]))

# Assign equipment parts from origin data
func _assign_equipment_parts(dataset_origin: Object, origin_dict: Dictionary):
	for part in Config.EQUIPMENT_KEYS:
		if origin_dict.has(part):
			var part_value = origin_dict[part]
			if part_value == "empty_part":
				dataset_origin.set(part, Dataset.empty_part)
			else:
				dataset_origin.set(part, get_by_id(Dataset.parts, part_value))

# Re-used from base game to access here
func get_by_id(array: Array, id):
	for i in array:
		if i.id == id:
			return i
	return null
