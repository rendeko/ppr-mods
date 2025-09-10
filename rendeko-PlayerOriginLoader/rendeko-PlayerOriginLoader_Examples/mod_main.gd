extends Node

const MOD_NAME = "rendeko-PlayerOriginLoader_Examples"

func _init():
	ModLoaderLog.info("Initialized.", MOD_NAME)

func _ready():
	var PlayerOriginLoader = get_node_or_null("/root/ModLoader/rendeko-PlayerOriginLoader")
	if PlayerOriginLoader:
		ModLoaderLog.debug("Attempting to load origins.", MOD_NAME)
		PlayerOriginLoader.register_custom_origin(blade_origin)
		PlayerOriginLoader.register_custom_origin(mechanic_origin)
		PlayerOriginLoader.register_custom_origin(eclipse_commander_origin)
		PlayerOriginLoader.register_custom_origin(peacekeeper_origin)
		PlayerOriginLoader.register_custom_origin(fritfroer_origin)
	else:
		ModLoaderLog.error("PlayerOriginLoader not found.", MOD_NAME)

var blade_origin = {
	"id": "Blade",
	"bodytype": "BodyFemale1",
	"body_material": "res://Materials/Human/efp_material_mech_department.tres",
	"face_material": "res://Materials/Human/face_material_1.tres",
	"strength": 3,
	"speed": 12,
	"perception": 12,
	"agility": 9,
	"bioenergy": 5,
	"vitality": 5,
	"luck": 5,
	"lack": 3,
	"dna_damage": 0,
	"weapon_1": "Dagger",
	"weapon_2": "Benedetta B56",
	"l_weapon": "Cord-12.7mm",
	"r_weapon": "HX G600",
	"a_weapon": "FM SB900",
	"torso": "empty_part",
	"head": "empty_part",
	"arms": "empty_part",
	"legs": "empty_part",
	"slot_1": "Standard Flashlight",
	"slot_2": "empty_part",
	"mech_core": "EFP Light Core",
	"mech_armor": "EFP Light Armor",
	"mech_legs": "EFP Light Legs",
	"mech_engine": "Type 1 Orgone Engine",
	"mech_slot_1": "Targeting Computer",
	"mech_slot_2": "Night Vision Unit",
	"starting_items": {
		"Cocaine Grade C": 5,
		"EFP Cigarette Pack": 5
	},
	"custom": {
		"headtype": "Head_Female",
		"has_hair": true,
		"hair_material": "res://Materials/Human/face_material_2.tres",
		"legstype": "LegsFemale1"
	}
}

var mechanic_origin = {
	"id": "Mechanic",
	"bodytype": "BodyFemale1",
	"body_material": "res://Materials/Human/efp_material_mech_department.tres",
	"face_material": "res://Materials/Human/face_material_5.tres",
	"strength": 3,
	"speed": 6,
	"perception": 15,
	"agility": 6,
	"bioenergy": 15,
	"vitality": 15,
	"luck": 5,
	"lack": 5,
	"dna_damage": 0,
	"weapon_1": "MD-37",
	"weapon_2": "Lupara",
	"l_weapon": "Benedetta M6V",
	"r_weapon": "MR-37V",
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
	"mech_slot_2": "EFP Siren",
	"starting_items": {
		"Breaching Charge": 3,
		"Defuse Kit": 3,
		"EFP Cigarette Pack": 1
	},
	"custom": {
		"headtype": "Head_Female",
		"has_hair": true,
		"hair_material": "res://Materials/Human/face_material_5.tres",
		"legstype": "LegsFemale1",
	}
}

var eclipse_commander_origin = {
	"id": "Eclipse Commander",
	"bodytype": "BodyMale1",
	"body_material": "res://Materials/Human/efp_material_1.tres",
	"face_material": "res://Materials/Human/face_material_8.tres",
	"strength": 5,
	"speed": 10,
	"perception": 8,
	"agility": 5,
	"bioenergy": 10,
	"vitality": 5,
	"luck": 5,
	"lack": 8,
	"dna_damage": 0,
	"weapon_1": "Automag V",
	"weapon_2": "EFP KZ-24",
	"l_weapon": "Rheinstahl Riotgun",
	"r_weapon": "Ikon 25mm Rifle",
	"a_weapon": "V134 Smallgun",
	"torso": "empty_part",
	"head": "empty_part",
	"arms": "empty_part",
	"legs": "empty_part",
	"slot_1": "Discreet Flashlight",
	"slot_2": "empty_part",
	"mech_core": "EFP Heavy Core",
	"mech_armor": "EFP Standard Armor",
	"mech_legs": "EFP Heavy Legs",
	"mech_engine": "Type 1 Orgone Engine",
	"mech_slot_1": "Targeting Computer",
	"mech_slot_2": "Night Vision Unit",
	"starting_items": {
		"Energy Drink": 5,
		"EFP Cigarette Pack": 2
	},
	"custom": {
		"head_mesh": "res://Models/orbhead.obj",
		"scale": 0.854
	}
}

var peacekeeper_origin = {
	"id": "Peacekeeper",
	"bodytype": "BodyMale2",
	"body_material": "res://Materials/Human/efp_material_2.tres",
	"face_material":"res://Materials/Human/face_material_4.tres",
	"strength": 15,
	"speed": 3,
	"perception": 3,
	"agility": 4,
	"bioenergy": 9,
	"vitality": 16,
	"luck": 5,
	"lack": 1,
	"dna_damage": 0,
	"weapon_1": "HX G6",
	"weapon_2": "SOG P337",
	"l_weapon": "Cord-12.7mm",
	"r_weapon": "Cord-12.7mm",
	"a_weapon": "FM SB900",
	"torso": "ESO Level IIIA Body Armor",
	"head": "Standard Composite Helmet",
	"arms": "empty_part",
	"legs": "empty_part",
	"slot_1": "Standard Flashlight",
	"slot_2": "empty_part",
	"mech_core": "EFP Standard Core",
	"mech_armor": "EFP Standard Armor",
	"mech_legs": "EFP Standard Legs",
	"mech_engine": "Type 1 Orgone Engine",
	"mech_slot_1": "Advanced Targeting Computer",
	"mech_slot_2": "EFP Siren",
	"starting_items": {
		"Breaching Charge": 5,
		"Cocaine Grade A": 5
	}
}

var fritfroer_origin = {
	"id": "Fritfrøer",
	"bodytype": "BodyMale1",
	"body_material": "res://Materials/Human/frogman.tres",
	"face_material":"res://Materials/Human/face_material_frogman_1.tres",
	"strength": 25,
	"speed": 20,
	"perception": 35,
	"agility": 20,
	"bioenergy": 15,
	"vitality": 20,
	"luck": 20,
	"lack": 5,
	"dna_damage": 0,
	"weapon_1": "RBK-74",
	"weapon_2": "HX SDAP5",
	"l_weapon": "RBK-74",
	"r_weapon": "RBK-74",
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
	"mech_slot_2": "EFP Siren",
	"starting_items": {
		"Breaching Charge": 3,
		"Defuse Kit": 3,
		"EFP Cigarette Pack": 1
	}
}

