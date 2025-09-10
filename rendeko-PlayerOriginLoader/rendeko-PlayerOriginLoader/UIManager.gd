# UIManager - Handles UI connections and screen detection
extends Node

const Config = preload("res://mods-unpacked/rendeko-PlayerOriginLoader/Config.gd")

var is_new_game_screen = false

# Setup UI connections for a player stats node
func setup_ui_connections(player_stats_node: Node, item_selected_target: Object, item_selected_method: String, preview_handler_target: Object, preview_handler_method: String):
	if not player_stats_node:
		return false
	
	# Connect model preview visibility changes
	var model_preview = player_stats_node.get_node_or_null(Config.MODEL_PREVIEW_PATH)
	if model_preview and not model_preview.is_connected("visibility_changed", preview_handler_target, preview_handler_method):
		model_preview.connect("visibility_changed", preview_handler_target, preview_handler_method, [player_stats_node])
	
	# Connect origin list item selection
	var origin_list = player_stats_node.get_node_or_null(Config.ORIGIN_LIST_PATH)
	if origin_list and not origin_list.is_connected("item_selected", item_selected_target, item_selected_method):
		origin_list.connect("item_selected", item_selected_target, item_selected_method, [player_stats_node])
	
	return true

# Detect whether we're in New Game screen or In-Game menu
func detect_screen_type(player_stats_node: Node) -> bool:
	if not player_stats_node:
		return false
	
	var node_path = str(player_stats_node.get_path())
	is_new_game_screen = node_path.find("New_Game") != -1
	return is_new_game_screen

# Get current screen type
func is_new_game() -> bool:
	return is_new_game_screen

# Refresh the origin list in the UI
func refresh_origin_list(player_stats_node: Node) -> bool:
	if not player_stats_node:
		return false
	
	var origin_list = player_stats_node.get_node_or_null(Config.ORIGIN_LIST_PATH)
	if not origin_list:
		return false
	
	origin_list.clear()
	player_stats_node.update_classes()
	return true

# Get the skeleton node from player stats node
func get_skeleton_node(player_stats_node: Node) -> Node:
	if not player_stats_node:
		return null
	return player_stats_node.get_node_or_null(Config.SKELETON_PATH)

# Basic validation of required UI nodes
func validate_ui_nodes(player_stats_node: Node) -> bool:
	if not player_stats_node:
		return false
	
	var has_preview = player_stats_node.get_node_or_null(Config.MODEL_PREVIEW_PATH) != null
	var has_list = player_stats_node.get_node_or_null(Config.ORIGIN_LIST_PATH) != null
	var has_skeleton = player_stats_node.get_node_or_null(Config.SKELETON_PATH) != null
	
	return has_preview and has_list and has_skeleton