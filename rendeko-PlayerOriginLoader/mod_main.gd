extends Node

const MOD_NAME = "rendeko-PlayerOriginLoader"

# The folder where we'll store player origin json's
const origin_directory = "user://PlayerOriginLoader"

# Maybe define this inside another scope later. Needed here for now
var custom_origins = {}

func _init():
	ModLoaderLog.info("Initialized.", MOD_NAME)

func _ready():
	# Start scanning for custom origins
	custom_origins = get_origins_from_directory(origin_directory)
	# Check every node added to the scene tree
	get_tree().connect("node_added", self, "_on_node_added")

# When node is added to scene tree
func _on_node_added(node):
	if node.filename == "res://UI/Player_Stats.tscn" or "Player_Stats" in node.name:
		var model_preview_node = node.get_node("HBoxContainer/ViewportContainer")
		var origin_list_node = node.get_node("HBoxContainer/VBoxContainer/Class_List")
		
		# When the model preview appears, we know we're in the status or new game menu
		if not model_preview_node.is_connected("visibility_changed", self, "_model_preview_handler"):
				model_preview_node.connect("visibility_changed", self, "_model_preview_handler", [node])
		
		# When a new origin list item is selected, we need to map it to a origin and update the model 
		if not origin_list_node.is_connected("item_selected", self, "_on_item_selected"):
			origin_list_node.connect("item_selected", self, "_on_item_selected", [node])
	
	# Only using for player scaling at the moment
	if node.filename == "res://Player_Infantry.tscn" or "Player_Infantry" in node.name:
		var guy2_node = node.get_node("guy2")
		if not guy2_node.is_connected("tree_entered", self, "change_scale_from_origin"):
				if Dataset.player_stats.id != null:
					guy2_node.connect("tree_entered", self, "change_scale_from_origin", [node, Dataset.player_stats.id])

func get_origins_from_directory(origin_directory):
	var custom_origins = {}
	
	# Open PlayeroriginLoader in user save folder, iterate through files, validate them, then send to another function to be interpreted
	var dir = Directory.new()
	if dir.open(origin_directory) != OK:
		# maybe make this directory if not found?
		ModLoaderLog.error("origin directory " + origin_directory + " failed to open", MOD_NAME)
		return custom_origins
	
	if dir.list_dir_begin(true, true) != OK:
		ModLoaderLog.error("Failed to list files in directory " + origin_directory, MOD_NAME)
		return custom_origins
	
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.get_extension().to_lower() == "json" and not dir.current_is_dir():
			var file_path = dir.get_current_dir().plus_file(file_name)
			
			var file = File.new()
			if file.open(file_path, File.READ) == OK:
				ModLoaderLog.debug("File " + file_path + " was opened", MOD_NAME)
				var json_text = file.get_as_text()
				file.close()
				
				var parse_result = JSON.parse(json_text)
				if parse_result.error == OK:
					ModLoaderLog.debug("json was valid.", MOD_NAME)
					
					# get origin name from first key in json
					var custom_origin_name = parse_result.result.keys()[0]
					var origin_data = parse_result.result[custom_origin_name]
					custom_origins[custom_origin_name] = origin_data
					
					ModLoaderLog.debug("Added origin " + custom_origin_name + " to custom_origins", MOD_NAME)
				else:
					ModLoaderLog.error(
						"JSON error in %s: Line %d - %s" % [
							file_path,
							parse_result.error_line,
							parse_result.error_string
						], 
						MOD_NAME)
			else:
				ModLoaderLog.error("File " + file_path + " failed to open", MOD_NAME)
		
		file_name = dir.get_next()
	dir.list_dir_end()
	return custom_origins

# Duplicated from Data.gd to use here
func get_by_id(array: Array, id):
	for i in array:
		if i.id == id:
			return i
	return null

func _model_preview_handler(player_stats_node):
	var skeleton_node = player_stats_node.get_node("HBoxContainer/ViewportContainer/Viewport/guy/Animated_Mesh/Skeleton")
	add_custom_origins(player_stats_node)
	if Dataset.player_stats.id != null:
		var selected_origin_name = Dataset.player_stats.id
		replace_model(skeleton_node, selected_origin_name)

func empty_part_check(key):
	if key == "empty_part":
		return Dataset.empty_part
	else:
		return get_by_id(Dataset.parts, key)

func add_custom_origins(player_stats_node):
	# Print origin names
	#for p in Dataset.character_classes:
	#	ModLoaderLog.debug(p.id, MOD_NAME)
	
	# Make sure origin isn't already added first
	var origin_exists = false
	for p in custom_origins:
		for i in range(Dataset.character_classes.size()):
			if Dataset.character_classes[i].id == p:
				origin_exists = true
				#ModLoaderLog.info("origin " + Dataset.character_classes[i].id + " exists", MOD_NAME)
				break
		if not origin_exists:
			#ModLoaderLog.debug("Custom origin " + p + " doesn't exist yet. Adding...", MOD_NAME)
			var new_custom_origin = Dataset.Player.new()
			new_custom_origin.id = p
			new_custom_origin.bodytype = custom_origins[p]["bodytype"]
			if custom_origins[p].has("body_material"):
				new_custom_origin.body_material = load(custom_origins[p]["body_material"])
			if custom_origins[p].has("face_material"):
				new_custom_origin.face_material = load(custom_origins[p]["face_material"]) # doesn't seem to work?
			new_custom_origin.strength = custom_origins[p]["strength"]
			new_custom_origin.speed = custom_origins[p]["speed"]
			new_custom_origin.perception = custom_origins[p]["perception"]
			new_custom_origin.agility = custom_origins[p]["agility"]
			new_custom_origin.bioenergy = custom_origins[p]["bioenergy"]
			new_custom_origin.vitality = custom_origins[p]["vitality"]
			new_custom_origin.luck = custom_origins[p]["luck"]
			new_custom_origin.lack = custom_origins[p]["lack"]
			new_custom_origin.dna_damage = 0
			new_custom_origin.weapon_1 = get_by_id(Dataset.weapons, custom_origins[p]["weapon_1"])
			new_custom_origin.weapon_2 = get_by_id(Dataset.weapons, custom_origins[p]["weapon_2"])
			new_custom_origin.l_weapon = get_by_id(Dataset.weapons, custom_origins[p]["l_weapon"])
			new_custom_origin.r_weapon = get_by_id(Dataset.weapons, custom_origins[p]["r_weapon"])
			new_custom_origin.a_weapon = get_by_id(Dataset.weapons, custom_origins[p]["a_weapon"])
			new_custom_origin.torso = empty_part_check(custom_origins[p]["torso"])
			new_custom_origin.head = empty_part_check(custom_origins[p]["head"])
			new_custom_origin.arms = empty_part_check(custom_origins[p]["arms"])
			new_custom_origin.legs = empty_part_check(custom_origins[p]["legs"])
			new_custom_origin.slot_1 = empty_part_check(custom_origins[p]["slot_1"])
			new_custom_origin.slot_2 = empty_part_check(custom_origins[p]["slot_2"])
			new_custom_origin.mech_core = empty_part_check(custom_origins[p]["mech_core"])
			new_custom_origin.mech_armor = empty_part_check(custom_origins[p]["mech_armor"])
			new_custom_origin.mech_legs = empty_part_check(custom_origins[p]["mech_legs"])
			new_custom_origin.mech_engine = empty_part_check(custom_origins[p]["mech_engine"])
			new_custom_origin.mech_slot_1 = empty_part_check(custom_origins[p]["mech_slot_1"])
			new_custom_origin.mech_slot_2 = empty_part_check(custom_origins[p]["mech_slot_2"])
			if custom_origins[p].has("starting_items"):
				new_custom_origin.starting_items = custom_origins[p]["starting_items"]
			Dataset.character_classes.append(new_custom_origin)
			#ModLoaderLog.info("origin " + new_custom_origin.id + " was added.", MOD_NAME)
				
			# Refresh origin list
			var origin_list_node = player_stats_node.get_node("HBoxContainer/VBoxContainer/Class_List")
			origin_list_node.clear()
			player_stats_node.update_classes()
			ModLoaderLog.debug("Origin list refreshed", MOD_NAME)

func _on_item_selected(item, player_stats_node):
	# item_selected returns the index value of sorted array origin_List, not the text
	# So we'll need to iterate through our modified character_origins and match each origin ID (name) to its origin index within origin_List
	var mapped_custom_origin_list = {}
	var i = 0
	for p in Dataset.character_classes:
		mapped_custom_origin_list[i] = p.id
		i+=1
		#ModLoaderLog.info("Mapping slot " + str(i) + " to " + p.id, MOD_NAME)
	# Obtain our desired origin' ID
	var selected_origin_name = mapped_custom_origin_list[item]
	
	# Now that we've targeted the origin, replace the model
	var skeleton_node = player_stats_node.get_node("HBoxContainer/ViewportContainer/Viewport/guy/Animated_Mesh/Skeleton")
	replace_model(skeleton_node, selected_origin_name)

func replace_model(skeleton_node, selected_origin_name):
	ModLoaderLog.debug("Replacing model parts for origin " + selected_origin_name, MOD_NAME)
	
	# Need to define these here and set them later, so we know what node to apply materials to
	var head_node
	var body_node
	var legs_node
	
	# We'll hide all the MeshInstance's to reset the player model, then enable back the MeshInstance's being used
	for child in skeleton_node.get_children():
		if child is MeshInstance:
			child.visible = false
	
	# For now we'll ignore default origins. Ideally allow replacing them through custom_origins later
	var default_origins = ["Recruit", "Warrior Cop", "SWAT", "Detective", "Carabiniere", "Specialist", "CERH", "Mycoman", "Celestial Prisoner", "Cosplayer"]
	if default_origins.has(selected_origin_name):
		skeleton_node.get_node("Head").visible = true
		skeleton_node.get_node("LegsMale1").visible = true
		change_scale_from_origin(skeleton_node, selected_origin_name)
		# Since we're returning here, we'll have to check for our CustomHead node here too
		if skeleton_node.get_node("BoneAttachment").has_node ("CustomHead"):
			skeleton_node.get_node("BoneAttachment").get_node("CustomHead").queue_free()
		return
	
	# Handling model replacement fields
	if custom_origins[selected_origin_name]["bodytype"] != "BodyMale1":
		skeleton_node.get_node("BodyMale1").visible = false
		body_node = skeleton_node.get_node(custom_origins[selected_origin_name]["bodytype"])
		body_node.visible = true
	else:
		body_node = skeleton_node.get_node("BodyMale1")
		body_node.visible = true
	
	# Custom model fields
	if custom_origins[selected_origin_name]["custom"].has("headtype") and custom_origins[selected_origin_name]["custom"]["headtype"] != "Head":
		skeleton_node.get_node("Head").visible = false
		head_node = skeleton_node.get_node(custom_origins[selected_origin_name]["custom"]["headtype"])
		head_node.visible = true
	else:
		head_node = skeleton_node.get_node("Head")
		head_node.visible = true
	
	if custom_origins[selected_origin_name]["custom"].has("legstype") and custom_origins[selected_origin_name]["custom"]["legstype"] != "LegsMale1":
		skeleton_node.get_node("LegsMale1").visible = false
		legs_node = skeleton_node.get_node(custom_origins[selected_origin_name]["custom"]["legstype"])
		legs_node.visible = true
	else:
		legs_node = skeleton_node.get_node("LegsMale1")
		legs_node.visible = true
	
	if custom_origins[selected_origin_name]["custom"].has("has_hair") and custom_origins[selected_origin_name]["custom"]["has_hair"] == true:
		skeleton_node.get_node("Hair").visible = true
	else:
		skeleton_node.get_node("Hair").visible = false
	
	
	# Replacing the Head mesh on the skeleton doesn't work directly, probably because it's lacking bones etc.
	# We're gonna cheat by adding a subnode to the Head with our mesh, and since orbhead is huge, it'll hide the default head anyway
	# Later we could try blanking the Head mesh and using the subnode as our custom "head", but glb meshes should work later when export is added
	var helmet_bone_node = skeleton_node.get_node("BoneAttachment")
	
	var CustomHead = MeshInstance.new()
	if custom_origins[selected_origin_name]["custom"].has("head_mesh"):
		CustomHead.mesh = load(custom_origins[selected_origin_name]["custom"]["head_mesh"])
	CustomHead.name = "CustomHead"
	CustomHead.skeleton = get_parent().get_path()
	#CustomHead.skin = head_node.skin
	CustomHead.scale.x = 3.18
	CustomHead.scale.y = 3.18
	CustomHead.scale.z = 3.18
	CustomHead.translation.y = -1.168
	
	# Add CustomHead node if head_mesh is defined, otherwise remove it from custom origin
	if custom_origins[selected_origin_name]["custom"].has("head_mesh") and helmet_bone_node.has_node("CustomHead") == false:
		helmet_bone_node.add_child(CustomHead)
		#ModLoaderLog.debug("Adding customhead", MOD_NAME)
	elif helmet_bone_node.has_node ("CustomHead"):
		# Delete the node. We could just hide it, but I'm unsure if it would impact hitboxes
		helmet_bone_node.get_node("CustomHead").queue_free()
		#ModLoaderLog.debug("removing customhead", MOD_NAME)
		
	# Textures (applied after meshes are set)
	if custom_origins[selected_origin_name].has("face_material"):
		head_node.set_surface_material(0, load(custom_origins[selected_origin_name]["face_material"]))
	elif custom_origins[selected_origin_name].has("face_material"):
		head_node.get_node("CustomHead").set_surface_material(0, load(custom_origins[selected_origin_name]["face_material"]))
	else:
		head_node.set_surface_material(0, head_node.material_override)
		
	# Since we're only using one big custom head for now, we'll just double assign the face texture if CustomHead exists
	if helmet_bone_node.has_node("CustomHead"):
		helmet_bone_node.get_node("CustomHead").set_surface_material(0, load(custom_origins[selected_origin_name]["face_material"]))
		#ModLoaderLog.debug("setting customhead texture", MOD_NAME)
	
	# Custom texture fields
	if custom_origins[selected_origin_name]["custom"].has("hair_material"):
		skeleton_node.get_node("Hair").set_surface_material(0, load(custom_origins[selected_origin_name]["custom"]["hair_material"]))
	else:
		skeleton_node.get_node("Hair").set_surface_material(0, head_node.material_override)

	# Player_Model_Preview.gd runs after this function and resets the armor scaling, so we'll need a function after it
	call_deferred("replace_model_deferred", skeleton_node, selected_origin_name, body_node, legs_node)
	
func replace_model_deferred(skeleton_node, selected_origin_name, body_node, legs_node):
	# Fixing armor scaling
	if skeleton_node.has_node("BoneAttachment3/Armor") and custom_origins[selected_origin_name]["bodytype"] == "BodyFemale1":
		var armor_node = skeleton_node.get_node("BoneAttachment3/Armor")
		#ModLoaderLog.debug("Running custom scaling", MOD_NAME)
		armor_node.scale.x = 3
		armor_node.scale.y = 3
		armor_node.scale.z = 2.75
	
	# Leg texturing. The else condition was always behind one selection, so deferring it here to fix it
	if custom_origins[selected_origin_name]["custom"].has("legs_material"):
		legs_node.set_surface_material(0, load(custom_origins[selected_origin_name]["custom"]["legs_material"]))
	else:
		# It seems we can't reliably copy materials from body_node without forcibly updating it beforehand
		legs_node.set_surface_material(0, body_node.material_override)
	
	# Scaling (on status screen and in-game)
	change_scale_from_origin(skeleton_node, selected_origin_name)

# Only using this for player scaling for now
func change_scale_from_origin(input_node, selected_origin_name):
	#ModLoaderLog.debug("Updating scale", MOD_NAME)
	if custom_origins.has(selected_origin_name) and custom_origins[selected_origin_name]["custom"].has("scale"):
		#ModLoaderLog.debug("custom scale", MOD_NAME)
		input_node.scale.x = custom_origins[selected_origin_name]["custom"]["scale"]
		input_node.scale.y = custom_origins[selected_origin_name]["custom"]["scale"]
		input_node.scale.z = custom_origins[selected_origin_name]["custom"]["scale"]
	else:
		#ModLoaderLog.debug("default scale", MOD_NAME)
		input_node.scale.x = 1
		input_node.scale.y = 1
		input_node.scale.z = 1
