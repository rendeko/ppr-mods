extends Node

const Config = preload("res://mods-unpacked/rendeko-PlayerOriginLoader/Config.gd")

# Main model replacement workflow
func replace_model(skeleton_node: Node, origin_name: String, origin_registry: Object, ui_manager: Object):
	if not skeleton_node:
		ModLoaderLog.error("Skeleton node is null", Config.MOD_NAME)
		return
	
	ModLoaderLog.debug("Replacing model parts for origin: " + origin_name, Config.MOD_NAME)
	
	var origin_data = origin_registry.get_origin(origin_name)
	if origin_data.empty():
		ModLoaderLog.warning("No origin data found for: " + origin_name, Config.MOD_NAME)
		return
	
	# Validate skeleton structure
	if not validate_skeleton_structure(skeleton_node):
		ModLoaderLog.error("Skeleton validation failed for: " + origin_name, Config.MOD_NAME)
		return
	
	# Step 1: Hide all existing mesh instances
	hide_all_mesh_instances(skeleton_node)
	# Step 2: Setup basic model parts and get references
	var model_nodes = setup_origin_parts(skeleton_node, origin_data)
	# Step 3: Setup custom meshes (head and hair)
	setup_custom_meshes(skeleton_node, origin_data)
	# Step 4: Apply materials to all components
	apply_all_materials(skeleton_node, origin_data, model_nodes)
	# Step 5: Apply scaling
	var is_new_game = ui_manager.is_new_game() if ui_manager else false
	call_deferred("apply_deferred_operations", skeleton_node, origin_name, origin_data, model_nodes, is_new_game)

# Hide all mesh instances in the skeleton
func hide_all_mesh_instances(skeleton_node: Node):
	for child in skeleton_node.get_children():
		if child is MeshInstance:
			if child.visible:
				child.visible = false

# Setup basic origin parts (body, head, legs, hair)
func setup_origin_parts(skeleton_node: Node, origin_data: Dictionary) -> Dictionary:
	var model_nodes = {}
	var bodytype = origin_data.get("bodytype", Config.DEFAULT_MALE_BODY)
	
	# Setup body
	model_nodes.body = skeleton_node.get_node_or_null(bodytype)
	if model_nodes.body:
		model_nodes.body.visible = true
	else:
		ModLoaderLog.error("Body type not found: " + bodytype, Config.MOD_NAME)
	
	# Setup head
	var custom_data = origin_data.get("custom", {})
	var head_type = custom_data.get("headtype", Config.DEFAULT_HEAD)
	model_nodes.head = skeleton_node.get_node_or_null(head_type)
	if not model_nodes.head:
		model_nodes.head = skeleton_node.get_node_or_null(Config.DEFAULT_HEAD)
	
	# Only show head if there's no custom head mesh
	if model_nodes.head and not custom_data.has("head_mesh"):
		model_nodes.head.visible = true
	
	# Setup legs
	var legs_type = custom_data.get("legstype", Config.DEFAULT_MALE_LEGS)
	model_nodes.legs = skeleton_node.get_node_or_null(legs_type)
	if not model_nodes.legs:
		model_nodes.legs = skeleton_node.get_node_or_null(Config.DEFAULT_MALE_LEGS)
	if model_nodes.legs:
		model_nodes.legs.visible = true
	else:
		ModLoaderLog.error("Legs type not found: " + legs_type, Config.MOD_NAME)
	
	# Setup hair visibility
	var hair_node = skeleton_node.get_node_or_null(Config.HAIR_NODE_NAME)
	if hair_node:
		if custom_data.get("has_hair", false) and not custom_data.has("hair_mesh"):
			hair_node.visible = true
		else:
			hair_node.visible = false
	return model_nodes

# Setup custom meshes (head and hair)
func setup_custom_meshes(skeleton_node: Node, origin_data: Dictionary):
	var bone_attachment = skeleton_node.get_node_or_null(Config.BONE_ATTACHMENT_PATH)
	if not bone_attachment:
		return
	
	var custom_data = origin_data.get("custom", {})
	
	# Custom head creation and cleanup
	if custom_data.has("head_mesh"):
		create_custom_mesh(bone_attachment, custom_data["head_mesh"], Config.CUSTOM_HEAD_NODE_NAME,
			Vector3(Config.CUSTOM_HEAD_SCALE, Config.CUSTOM_HEAD_SCALE, Config.CUSTOM_HEAD_SCALE),
			Vector3(0, Config.CUSTOM_HEAD_Y_OFFSET, 0))
	else:
		# Clean up when head_mesh is removed from custom_data
		if bone_attachment.has_node(Config.CUSTOM_HEAD_NODE_NAME):
			var existing_head = bone_attachment.get_node(Config.CUSTOM_HEAD_NODE_NAME)
			bone_attachment.remove_child(existing_head)
			existing_head.free()
	
	# Custom hair creation and cleanup
	if custom_data.has("hair_mesh"):
		create_custom_mesh(bone_attachment, custom_data["hair_mesh"], Config.CUSTOM_HAIR_NODE_NAME,
			Vector3(Config.CUSTOM_HAIR_SCALE, Config.CUSTOM_HAIR_SCALE, Config.CUSTOM_HAIR_SCALE),
			Vector3(0, Config.CUSTOM_HAIR_Y_OFFSET, 0))
	else:
		# Clean up when hair_mesh is removed from custom_data
		if bone_attachment.has_node(Config.CUSTOM_HAIR_NODE_NAME):
			var existing_hair = bone_attachment.get_node(Config.CUSTOM_HAIR_NODE_NAME)
			bone_attachment.remove_child(existing_hair)
			existing_hair.free()

# Create a custom mesh instance
func create_custom_mesh(bone_attachment: Node, mesh_path: String, node_name: String, scale: Vector3, offset: Vector3):
	# Delete existing if already exists
	if bone_attachment.has_node(node_name):
		var existing_node = bone_attachment.get_node(node_name)
		bone_attachment.remove_child(existing_node)
		existing_node.free()
	
	# Load and create new mesh
	var mesh_resource = load(mesh_path)
	if not mesh_resource:
		ModLoaderLog.error("Failed to load mesh: " + mesh_path, Config.MOD_NAME)
		return
	
	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = mesh_resource
	mesh_instance.name = node_name
	mesh_instance.skeleton = get_parent().get_path()
	mesh_instance.scale = scale
	mesh_instance.translation = offset
	
	bone_attachment.add_child(mesh_instance)
	#ModLoaderLog.debug("Created custom mesh: " + node_name, Config.MOD_NAME)

# Apply all materials to model components
func apply_all_materials(skeleton_node: Node, origin_data: Dictionary, model_nodes: Dictionary):
	var body_node = model_nodes.get("body")
	var head_node = model_nodes.get("head")
	var bone_attachment = skeleton_node.get_node_or_null(Config.BONE_ATTACHMENT_PATH)
	
	# Apply body material
	if body_node and origin_data.has("body_material"):
		var body_material = load(origin_data["body_material"])
		if body_material:
			body_node.set_surface_material(0, body_material)
	
	# Apply face material
	if head_node and origin_data.has("face_material"):
		var face_material = load(origin_data["face_material"])
		if face_material:
			head_node.set_surface_material(0, face_material)
			# Apply face material to custom head if it exists
			if bone_attachment:
				var custom_head = bone_attachment.get_node_or_null(Config.CUSTOM_HEAD_NODE_NAME)
				if custom_head:
					custom_head.set_surface_material(0, face_material)
	
	# Apply hair material
	var hair_node = skeleton_node.get_node_or_null(Config.HAIR_NODE_NAME)
	var custom_data = origin_data.get("custom", {})
	if hair_node and custom_data.has("hair_material"):
		var hair_material = load(custom_data["hair_material"])
		if hair_material:
			hair_node.set_surface_material(0, hair_material)
			# Apply hair material to custom hair if it exists
			if bone_attachment:
				var custom_hair = bone_attachment.get_node_or_null(Config.CUSTOM_HAIR_NODE_NAME)
				if custom_hair:
					custom_hair.set_surface_material(0, hair_material)
	# Hair fallback to head material if unspecified
	elif hair_node and head_node:
		hair_node.set_surface_material(0, head_node.material_override)

# Some functions must be done deferred, so we do those here
func apply_deferred_operations(skeleton_node: Node, origin_name: String, origin_data: Dictionary, model_nodes: Dictionary, is_new_game: bool):
	# Apply player scaling
	apply_player_scale(skeleton_node, origin_name, get_parent().origin_registry)
	
	# Apply leg materials with body fallback
	var legs_node = model_nodes.get("legs")
	var body_node = model_nodes.get("body")
	var custom_data = origin_data.get("custom", {})
	
	if legs_node and custom_data.has("legs_material"):
		var legs_material = load(custom_data["legs_material"])
		if legs_material:
			legs_node.set_surface_material(0, legs_material)
	elif legs_node and body_node:
		legs_node.set_surface_material(0, body_node.material_override)
	
	# Apply armor scaling for female body type
	var bodytype = origin_data.get("bodytype", "")
	if bodytype == Config.DEFAULT_FEMALE_BODY:
		var armor_node = skeleton_node.get_node_or_null(Config.BONE_ATTACHMENT3_ARMOR_PATH)
		if armor_node:
			armor_node.scale = Vector3(Config.FEMALE_ARMOR_SCALE_XY, Config.FEMALE_ARMOR_SCALE_XY, Config.FEMALE_ARMOR_SCALE_Z)
	
	# Apply helmet scaling
	apply_helmet_scaling(skeleton_node, is_new_game)

# Apply player scale based on origin settings
func apply_player_scale(node: Node, origin_name: String, origin_registry: Object):
	if not node or not origin_registry.has_origin(origin_name):
		ModLoaderLog.warning("Cannot apply scaling, node null or origin not found", Config.MOD_NAME)
		return
	
	var origin_data = origin_registry.get_origin(origin_name)
	var custom_data = origin_data.get("custom", {})
	var scale_value = custom_data.get("scale", Config.DEFAULT_SCALE)
	
	node.scale = Vector3(scale_value, scale_value, scale_value)
	#ModLoaderLog.debug("Applied player scale: " + str(scale_value) + " to " + node.name, Config.MOD_NAME)

# Apply helmet scaling
func apply_helmet_scaling(skeleton_node: Node, is_new_game: bool):
	var helmet_node = skeleton_node.get_node_or_null(Config.HELMET_PATH)
	if not helmet_node or Dataset.player_stats.head.id == "Empty":
		return
	
	var hair_node = skeleton_node.get_node_or_null(Config.HAIR_NODE_NAME)
	var bone_attachment = skeleton_node.get_node_or_null(Config.BONE_ATTACHMENT_PATH)
	
	# Check if hair is visible
	var has_visible_hair = false
	if hair_node and hair_node.visible:
		has_visible_hair = true
	elif bone_attachment and bone_attachment.has_node(Config.CUSTOM_HAIR_NODE_NAME):
		has_visible_hair = true
	
	# Apply helmet scaling
	var helmet_scale = Vector3(Config.DEFAULT_HELMET_SCALE, Config.DEFAULT_HELMET_SCALE, Config.DEFAULT_HELMET_SCALE)
	# If hair is visible, scale up slightly
	if has_visible_hair:
		helmet_scale = Vector3(Config.HELMET_HAIR_SCALE, Config.HELMET_HAIR_SCALE, Config.HELMET_HAIR_SCALE)
	
	# New game screen requires flipped helmet scaling for helmets to appear for some reason, so we'll do that here
	if is_new_game and helmet_scale.x > 0:
		helmet_scale = helmet_scale * -1
	
	helmet_node.scale = helmet_scale

# Reset model to default state
func reset_model_to_default(skeleton_node: Node):
	if not skeleton_node:
		return
	
	# Hide all meshes
	hide_all_mesh_instances(skeleton_node)

	var bone_attachment = skeleton_node.get_node_or_null(Config.BONE_ATTACHMENT_PATH)
	if not bone_attachment:
		ModLoaderLog.error("BoneAttachment node not found", Config.MOD_NAME)
		return null
	
	# Clean up custom meshes
	if bone_attachment:
		if bone_attachment.has_node(Config.CUSTOM_HEAD_NODE_NAME):
			bone_attachment.get_node(Config.CUSTOM_HEAD_NODE_NAME).queue_free()
		
		if bone_attachment.has_node(Config.CUSTOM_HAIR_NODE_NAME):
			bone_attachment.get_node(Config.CUSTOM_HAIR_NODE_NAME).queue_free()
	
	# Show default parts
	var default_body = skeleton_node.get_node_or_null(Config.DEFAULT_MALE_BODY)
	if default_body:
		default_body.visible = true
	var default_head = skeleton_node.get_node_or_null(Config.DEFAULT_HEAD)
	if default_head:
		default_head.visible = true
	var default_legs = skeleton_node.get_node_or_null(Config.DEFAULT_MALE_LEGS)
	if default_legs:
		default_legs.visible = true

# Validate skeleton node has required structure
func validate_skeleton_structure(skeleton_node: Node) -> bool:
	if not skeleton_node:
		ModLoaderLog.error("Skeleton node is null", Config.MOD_NAME)
		return false
	
	# Check for bone attachment
	var bone_attachment = skeleton_node.get_node_or_null(Config.BONE_ATTACHMENT_PATH)
	if not bone_attachment:
		ModLoaderLog.error("BoneAttachment not found at: " + Config.BONE_ATTACHMENT_PATH, Config.MOD_NAME)
		return false
	
	# Check for basic body parts
	var male_body = skeleton_node.get_node_or_null(Config.DEFAULT_MALE_BODY)
	var female_body = skeleton_node.get_node_or_null(Config.DEFAULT_FEMALE_BODY)
	if not male_body and not female_body:
		ModLoaderLog.error("No body meshes found", Config.MOD_NAME)
		return false
	
	return true
