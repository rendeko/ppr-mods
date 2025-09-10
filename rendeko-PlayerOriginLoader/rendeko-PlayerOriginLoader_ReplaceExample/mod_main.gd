extends Node

const MOD_NAME = "rendeko-PlayerOriginLoader_ReplaceExample"

func _init():
	ModLoaderLog.info("Initialized.", MOD_NAME)

func _ready():
	var PlayerOriginLoader = get_node_or_null("/root/ModLoader/rendeko-PlayerOriginLoader")
	if PlayerOriginLoader:
		ModLoaderLog.debug("Attempting to load origins.", MOD_NAME)
		PlayerOriginLoader.register_custom_origin(teto_recruit_origin)
	else:
		ModLoaderLog.error("PlayerOriginLoader not found.", MOD_NAME)

var teto_recruit_origin = {
	"id": "Recruit", 
	"bodytype": "BodyMale1",
	"body_material": "res://Materials/Human/civ_material_3.tres",
	"face_material": "res://Materials/Human/face_material_7.tres",
	"strength": 8, 
	"speed": 8,
	"perception": 8,
	"agility": 8,   
	"bioenergy": 6, 
	"vitality": 8,  
	"luck": 6, 
	"lack": 3,
	"dna_damage": 0,
	"weapon_1": "Automag V",
	"weapon_2": "EFP KZ-24",
	"l_weapon": "Benedetta M6V",
	"r_weapon": "HX G600",
	"a_weapon": "FM SB900",
	"torso": "empty_part",
	"head": "empty_part",
	"arms": "empty_part",
	"legs": "empty_part",
	"slot_1": "Standard Flashlight",
	"slot_2": "HACKMAN 1",
	"mech_core": "EFP Standard Core",
	"mech_armor": "EFP Standard Armor",
	"mech_legs": "EFP Standard Legs",
	"mech_engine": "Type 1 Orgone Engine",
	"mech_slot_1": "Targeting Computer",
	"mech_slot_2": "Night Vision Unit",
	"starting_items": {
		"Breaching Charge": 3,
		"Defuse Kit": 3,
		"EFP Cigarette Pack": 1
	},
	"custom": {
		"has_hair": true,
		"hair_mesh": "res://mods-unpacked/rendeko-PlayerOriginLoader_ReplaceExample/assets/rendeko-PlayerOriginLoader_ReplaceExample_tetohair.obj",
		"hair_material": "res://mods-unpacked/rendeko-PlayerOriginLoader_ReplaceExample/assets/rendeko-PlayerOriginLoader_ReplaceExample_tetohair.tres"
	}
}
