# Configuration constants for PlayerOriginLoader
extends Node

const MOD_NAME = "rendeko-PlayerOriginLoader"

# Scene paths
const IN_GAME_MENU_SCENE = "res://In_Game_Menu.tscn"
const PLAYER_STATS_SCENE = "res://UI/Player_Stats.tscn"
const PLAYER_INFANTRY_SCENE = "res://Player_Infantry.tscn"

# UI node paths
const MODEL_PREVIEW_PATH = "HBoxContainer/ViewportContainer"
const ORIGIN_LIST_PATH = "HBoxContainer/VBoxContainer/Class_List"
const SKELETON_PATH = "HBoxContainer/ViewportContainer/Viewport/guy/Animated_Mesh/Skeleton"

# Scaling constants
const DEFAULT_SCALE = 1.0
const CUSTOM_HEAD_SCALE = 3.18
const CUSTOM_HEAD_Y_OFFSET = -1.168
const FEMALE_ARMOR_SCALE_XY = 3.0
const FEMALE_ARMOR_SCALE_Z = 3.15
const HELMET_HAIR_SCALE = 3.25
const DEFAULT_HELMET_SCALE = 3.18
const CUSTOM_HAIR_SCALE = 3.25
const CUSTOM_HAIR_Y_OFFSET = 0.6

# Dataset keys for character data
const STAT_KEYS = ["strength", "speed", "perception", "agility", "bioenergy", "vitality", "luck", "lack"]
const WEAPON_KEYS = ["weapon_1", "weapon_2", "l_weapon", "r_weapon", "a_weapon"]
const EQUIPMENT_KEYS = ["torso", "head", "arms", "legs", "slot_1", "slot_2", "mech_core", "mech_armor", "mech_legs", "mech_engine", "mech_slot_1", "mech_slot_2"]

# Bone and attachment paths
const BONE_ATTACHMENT_PATH = "BoneAttachment"
const BONE_ATTACHMENT3_ARMOR_PATH = "BoneAttachment3/Armor"
const CUSTOM_HEAD_NODE_NAME = "CustomHead"
const CUSTOM_HAIR_NODE_NAME = "CustomHair"
const HELMET_PATH = "BoneAttachment/Helmet"
const HAIR_NODE_NAME = "Hair"

# Default body part names
const DEFAULT_MALE_BODY = "BodyMale1"
const DEFAULT_FEMALE_BODY = "BodyFemale1"
const DEFAULT_MALE_LEGS = "LegsMale1"
const DEFAULT_FEMALE_LEGS = "LegsFemale1"
const DEFAULT_HEAD = "Head"
const DEFAULT_FEMALE_HEAD = "Head_Female"

# Empty part identifier
const EMPTY_PART = "empty_part"