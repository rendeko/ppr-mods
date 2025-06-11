extends Node

const MOD_NAME = "rendeko-UnloadSFX"

func _init():
	ModLoaderLog.info("Initialized.", MOD_NAME)

func _ready():
	# check every node added to the scene tree
	get_tree().connect("node_added", self, "_on_node_added")

# when node is added to scene tree
func _on_node_added(node):
	# check if node is a weapon node
	if node.filename == "res://Weapon.tscn" or "Weapon" in node.name:
		# if it is, look for child Reload_Complete node (unloading uses the Reload_Complete SFX)
		if node.has_node("Reload_Complete"):
			var reload_sound = node.get_node("Reload_Complete")
			#ModLoaderLog.info("Found Reload_Complete in new weapon: " + node.name, MOD_NAME)
			
			# connect the Reload_Complete finished signal to our new function
			if not reload_sound.is_connected("finished", self, "_on_audio_finished"):
				reload_sound.connect("finished", self, "_on_audio_finished", [node])

# runs when Reload_Complete finished signal emits
func _on_audio_finished(weapon):
	#ModLoaderLog.info("Reload sound finished playing on weapon: " + weapon.name, MOD_NAME)
	
	# to mimic unload behaviour, we need the Reload_Complete sound finished AND no new ammo entering the mag
	var empty_clip_after_reload = false
	
	if "mag_ammo" in weapon:
		#ModLoaderLog.info(weapon.name + " has variable mag_ammo", MOD_NAME)
		if weapon.mag_ammo == 0:
				empty_clip_after_reload = true
				#ModLoaderLog.info("mag_ammo is 0, empty_clip_reload set to " + str(empty_clip_after_reload), MOD_NAME)
	
	# once we have confirmed no ammo in mag
	if empty_clip_after_reload == true:
		# make sure the weapon has the Unload_Complete node, then play it
		if weapon.has_node("Unload_Complete"):
			weapon.get_node("Unload_Complete").play()
			ModLoaderLog.info("Playing Unload_Complete from weapon " + weapon.name, MOD_NAME)
		#else:
		#	ModLoaderLog.error("Weapon does not have Unload_Complete node", MOD_NAME)
