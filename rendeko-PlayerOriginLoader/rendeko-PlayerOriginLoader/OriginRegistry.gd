# OriginRegistry - Manages origin data storage and access
extends Node

const Config = preload("res://mods-unpacked/rendeko-PlayerOriginLoader/Config.gd")

var mod_origins = {}
var itemlist_to_origin_map = {}

# Register a custom origin
func register_origin(origin_dict: Dictionary) -> bool:
	var id = origin_dict.get("id", "")
	if id.empty():
		ModLoaderLog.error("Origin is missing ID", Config.MOD_NAME)
		return false
	
	if not mod_origins.has(id):
		mod_origins[id] = origin_dict
		ModLoaderLog.info("Registered origin: " + id, Config.MOD_NAME)
		return true
	else:
		ModLoaderLog.warning("Origin already registered: " + id, Config.MOD_NAME)
	return false

# Get origin data by ID
func get_origin(id: String) -> Dictionary:
	return mod_origins.get(id, {})

# Check if origin exists
func has_origin(id: String) -> bool:
	return mod_origins.has(id)

# Get all registered origins
func get_all_origins() -> Dictionary:
	return mod_origins

# Import default origins from Dataset
func import_default_origins():
	for origin in Dataset.character_classes:
		if not mod_origins.has(origin.id):
			var default_origin = {
				"id": origin.id,
				"bodytype": origin.bodytype,
			}
			mod_origins[origin.id] = default_origin

# Build mapping between ItemList indices and origin IDs
func build_itemlist_map() -> Dictionary:
	itemlist_to_origin_map.clear()
	var itemlist_index = 0
	
	for c in Dataset.character_classes:
		# Only add unlocked origins to sync with UI ItemList
		if Dataset.persistent.flags.find(c.unlock_flag) != -1 or c.unlock_flag == "":
			itemlist_to_origin_map[itemlist_index] = c.id
			itemlist_index += 1
	
	#ModLoaderLog.debug("Built itemlist mapping with " + str(itemlist_to_origin_map.size()) + " origins", Config.MOD_NAME)
	return itemlist_to_origin_map

# Get origin ID from ItemList selection index
func get_origin_id_from_itemlist_index(index: int) -> String:
	# Build the mapping if it's empty
	if itemlist_to_origin_map.empty():
		build_itemlist_map()
	
	return itemlist_to_origin_map.get(index, "")

# Find the index of an origin in Dataset.character_classes
func find_origin_index_in_dataset(origin_id: String) -> int:
	for i in range(Dataset.character_classes.size()):
		if Dataset.character_classes[i].id == origin_id:
			return i
	return -1

# Check if origins registry is empty
func is_empty() -> bool:
	return mod_origins.empty()