extends Node

# Slabs.array[grid_value][parameter]

# DISPLAYS DECORATION STUFF ON THE SIDE


var default_data = {}
func _init():
	# This only takes 1ms
	default_data["data"] = data.duplicate(true)
	default_data["doorslab_data"] = doorslab_data.duplicate(true)
	
func reset_slab_data_to_default(): # Reset data. Takes 1ms.
	data = default_data["data"].duplicate(true)
	doorslab_data = default_data["doorslab_data"].duplicate(true)


enum {
	NAME
	IS_SOLID # Whether units can walk there, and how fortified walls do their bitmask, AND for 3D generation optimization
	BITMASK_TYPE
	EDITOR_TAB
	WIBBLE_TYPE
	REMEMBER_TYPE
	IS_OWNABLE
}

var auto_wall_updates_these = {
	WALL_WITH_TORCH:null,
	WALL_WITH_BANNER:null,
	WALL_WITH_TWINS:null,
	WALL_WITH_WOMAN:null,
	WALL_WITH_PAIR:null,
	WALL_UNDECORATED:null,
}

enum {
	ROCK = 0,
	GOLD = 1,
	EARTH = 2,
	EARTH_WITH_TORCH = 3,
	WALL_WITH_BANNER = 4,
	WALL_WITH_TORCH = 5,
	WALL_WITH_TWINS = 6,
	WALL_WITH_WOMAN = 7,
	WALL_WITH_PAIR = 8,
	WALL_UNDECORATED = 9,
	PATH = 10,
	CLAIMED_GROUND = 11,
	LAVA = 12,
	WATER = 13,
	PORTAL = 14,
	PORTAL_WALL = 15,
	TREASURE_ROOM = 16,
	TREASURE_ROOM_WALL = 17,
	LIBRARY = 18,
	LIBRARY_WALL = 19,
	PRISON = 20,
	PRISON_WALL = 21,
	TORTURE_CHAMBER = 22,
	TORTURE_CHAMBER_WALL = 23,
	TRAINING_ROOM = 24,
	TRAINING_ROOM_WALL = 25,
	DUNGEON_HEART = 26,
	DUNGEON_HEART_WALL = 27,
	WORKSHOP = 28,
	WORKSHOP_WALL = 29,
	SCAVENGER_ROOM = 30,
	SCAVENGER_ROOM_WALL = 31,
	TEMPLE = 32,
	TEMPLE_WALL = 33,
	GRAVEYARD = 34,
	GRAVEYARD_WALL = 35,
	HATCHERY = 36,
	HATCHERY_WALL = 37,
	LAIR = 38,
	LAIR_WALL = 39,
	BARRACKS = 40,
	BARRACKS_WALL = 41,
	WOODEN_DOOR_1 = 42,
	WOODEN_DOOR_2 = 43,
	BRACED_DOOR_1 = 44,
	BRACED_DOOR_2 = 45,
	IRON_DOOR_1 = 46,
	IRON_DOOR_2 = 47,
	MAGIC_DOOR_1 = 48,
	MAGIC_DOOR_2 = 49,
	SLAB_50 = 50,
	BRIDGE = 51,
	GEMS = 52,
	GUARD_POST = 53,
	PURPLE_PATH = 54,
	# 58 doesn't exist within 1304 entries
	WALL_AUTOMATIC = 999,
}

var rooms_that_have_walls = {14:null,16:null,18:null,20:null,22:null,24:null,26:null,28:null,30:null,32:null,34:null,36:null,38:null,40:null}
########################################################################
# These are just to make it easier to read
const NOT_OWNABLE = false
const OWNABLE = true
const FLOOR_SLAB = false
const BLOCK_SLAB = true
enum {
	BITMASK_FLOOR
	BITMASK_BLOCK
	BITMASK_SIMPLE
	BITMASK_CLAIMED
	BITMASK_REINFORCED
	BITMASK_DOOR1
	BITMASK_DOOR2
}
enum {
	REMEMBER_PATH = 0
	REMEMBER_LAVA = 1
	REMEMBER_WATER = 2
}
enum {
	WIBBLE_OFF = 0
	WIBBLE_ON = 1
	WIBBLE_ANIMATED = 2
}
enum {
	TAB_MAINSLAB = 0
	TAB_OTHER = 1
	TAB_CUSTOM = 2
	TAB_STYLE = 3
	TAB_OWNER = 4
	TAB_NONE = 5
}
########################################################################
enum {
	FAKE_CUBE_DATA,
	FAKE_FLOOR_DATA,
	FAKE_RECOGNIZED_AS,
	FAKE_WIBBLE_EDGES,
}
enum {
	DOORSLAB_THING = 0,
	DOORSLAB_ORIENTATION = 1,
}
enum {
	DOORTHING_WOOD = 1
	DOORTHING_BRACED = 2
	DOORTHING_STEEL = 3
	DOORTHING_MAGIC = 4
}
#Slabs.door_data[slabID][DOORSLAB_THING]
#Slabs.door_data[slabID][DOORSLAB_ORIENTATION]
enum { # These might be backwards
	DOOR_ORIENT_NS = 0
	DOOR_ORIENT_EW = 1
}

func fetch_doorslab_data(slabID):
	var slabData = Slabs.data.get(slabID)
	if slabData:
		return doorslab_data.get(slabData[NAME])

var doorslab_data = { # Refer to Things.DATA_DOOR for door subtypes
	"DOOR_WOODEN" : [DOORTHING_WOOD, DOOR_ORIENT_EW],
	"DOOR_WOODEN2" : [DOORTHING_WOOD, DOOR_ORIENT_NS],
	"DOOR_BRACE" : [DOORTHING_BRACED, DOOR_ORIENT_EW],
	"DOOR_BRACE2" : [DOORTHING_BRACED, DOOR_ORIENT_NS],
	"DOOR_STEEL" : [DOORTHING_STEEL, DOOR_ORIENT_EW],
	"DOOR_STEEL2" : [DOORTHING_STEEL, DOOR_ORIENT_NS],
	"DOOR_MAGIC" : [DOORTHING_MAGIC, DOOR_ORIENT_EW],
	"DOOR_MAGIC2" : [DOORTHING_MAGIC, DOOR_ORIENT_NS],
}

#"DOOR_SECRET"
#"DOOR_SECRET2"


var fake_extra_data = {
	# 1000: [cube_data, floor_data, recognized_as, wibble_edges]
}

func fetch_name(slabID):
	var slabData = data.get(slabID)
	if slabData == null:
		return "Unknown Slab " + str(slabID)
	
	var nameID = slabData[NAME]
	
	var getName = Names.slabs.get(nameID)
	if getName == null:
		return nameID.capitalize()
	else:
		return getName

func fetch_idname(slabID):
	var slabData = data.get(slabID)
	if slabData:
		return slabData[NAME]
	return ""

var data = {
00: ["HARD",                  BLOCK_SLAB, BITMASK_BLOCK,         TAB_MAINSLAB,  WIBBLE_ON,       REMEMBER_PATH,  NOT_OWNABLE], # 0
01: ["GOLD",                  BLOCK_SLAB, BITMASK_BLOCK,         TAB_MAINSLAB,  WIBBLE_ON,       REMEMBER_PATH,  NOT_OWNABLE], # 1
02: ["DIRT",                  BLOCK_SLAB, BITMASK_BLOCK,         TAB_MAINSLAB,  WIBBLE_ON,       REMEMBER_PATH,  NOT_OWNABLE], # 2
03: ["TORCH_DIRT",            BLOCK_SLAB, BITMASK_BLOCK,         TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,  NOT_OWNABLE], # 3
04: ["DRAPE_WALL",            BLOCK_SLAB, BITMASK_REINFORCED,    TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 4
05: ["TORCH_WALL",            BLOCK_SLAB, BITMASK_REINFORCED,    TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 5
06: ["TWINS_WALL",            BLOCK_SLAB, BITMASK_REINFORCED,    TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 6
07: ["WOMAN_WALL",            BLOCK_SLAB, BITMASK_REINFORCED,    TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 7
08: ["PAIR_WALL",             BLOCK_SLAB, BITMASK_REINFORCED,    TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 8
09: ["DAMAGED_WALL",          BLOCK_SLAB, BITMASK_REINFORCED,    TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 9
10: ["PATH",                  FLOOR_SLAB, BITMASK_FLOOR,         TAB_MAINSLAB,  WIBBLE_ON,       REMEMBER_PATH,  NOT_OWNABLE], # 10
11: ["PRETTY_PATH",           FLOOR_SLAB, BITMASK_CLAIMED,       TAB_MAINSLAB,  WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 11
12: ["LAVA",                  FLOOR_SLAB, BITMASK_FLOOR,         TAB_MAINSLAB,  WIBBLE_ANIMATED, REMEMBER_LAVA,  NOT_OWNABLE], # 12
13: ["WATER",                 FLOOR_SLAB, BITMASK_FLOOR,         TAB_MAINSLAB,  WIBBLE_ANIMATED, REMEMBER_WATER, NOT_OWNABLE], # 13
14: ["ENTRANCE_ZONE",         FLOOR_SLAB, BITMASK_FLOOR,         TAB_MAINSLAB,  WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 14
15: ["ENTRANCE_WALL",         BLOCK_SLAB, BITMASK_REINFORCED,    TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 15
16: ["TREASURY_AREA",         FLOOR_SLAB, BITMASK_FLOOR,         TAB_MAINSLAB,  WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 16
17: ["TREASURY_WALL",         BLOCK_SLAB, BITMASK_REINFORCED,    TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 17
18: ["BOOK_SHELVES",          FLOOR_SLAB, BITMASK_FLOOR,         TAB_MAINSLAB,  WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 18
19: ["LIBRARY_WALL",          BLOCK_SLAB, BITMASK_REINFORCED,    TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 19
20: ["PRISON_AREA",           FLOOR_SLAB, BITMASK_FLOOR,         TAB_MAINSLAB,  WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 20
21: ["PRISON_WALL",           BLOCK_SLAB, BITMASK_REINFORCED,    TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 21
22: ["TORTURE_AREA",          FLOOR_SLAB, BITMASK_FLOOR,         TAB_MAINSLAB,  WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 22
23: ["TORTURE_WALL",          BLOCK_SLAB, BITMASK_REINFORCED,    TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 23
24: ["TRAINING_AREA",         FLOOR_SLAB, BITMASK_FLOOR,         TAB_MAINSLAB,  WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 24
25: ["TRAINING_WALL",         BLOCK_SLAB, BITMASK_REINFORCED,    TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 25
26: ["HEART_PEDESTAL",        FLOOR_SLAB, BITMASK_FLOOR,         TAB_MAINSLAB,  WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 26
27: ["HEART_WALL",            BLOCK_SLAB, BITMASK_REINFORCED,    TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 27
28: ["WORKSHOP_AREA",         FLOOR_SLAB, BITMASK_FLOOR,         TAB_MAINSLAB,  WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 28
29: ["WORKSHOP_WALL",         BLOCK_SLAB, BITMASK_REINFORCED,    TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 29
30: ["SCAVENGE_AREA",         FLOOR_SLAB, BITMASK_FLOOR,         TAB_MAINSLAB,  WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 30
31: ["SCAVENGER_WALL",        BLOCK_SLAB, BITMASK_REINFORCED,    TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 31
32: ["TEMPLE_POOL",           FLOOR_SLAB, BITMASK_FLOOR,         TAB_MAINSLAB,  WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 32
33: ["TEMPLE_WALL",           BLOCK_SLAB, BITMASK_REINFORCED,    TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 33
34: ["GRAVE_AREA",            FLOOR_SLAB, BITMASK_FLOOR,         TAB_MAINSLAB,  WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 34
35: ["GRAVE_WALL",            BLOCK_SLAB, BITMASK_REINFORCED,    TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 35
36: ["HATCHERY",              FLOOR_SLAB, BITMASK_FLOOR,         TAB_MAINSLAB,  WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 36
37: ["HATCHERY_WALL",         BLOCK_SLAB, BITMASK_REINFORCED,    TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 37
38: ["LAIR_AREA",             FLOOR_SLAB, BITMASK_FLOOR,         TAB_MAINSLAB,  WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 38
39: ["LAIR_WALL",             BLOCK_SLAB, BITMASK_REINFORCED,    TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 39
40: ["BARRACK_AREA",          FLOOR_SLAB, BITMASK_FLOOR,         TAB_MAINSLAB,  WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 40
41: ["BARRACK_WALL",          BLOCK_SLAB, BITMASK_REINFORCED,    TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 41
42: ["DOOR_WOODEN",           FLOOR_SLAB, BITMASK_DOOR1,         TAB_NONE,      WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 42
43: ["DOOR_WOODEN2",          FLOOR_SLAB, BITMASK_DOOR2,         TAB_MAINSLAB,  WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 43
44: ["DOOR_BRACE",            FLOOR_SLAB, BITMASK_DOOR1,         TAB_NONE,      WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 44
45: ["DOOR_BRACE2",           FLOOR_SLAB, BITMASK_DOOR2,         TAB_MAINSLAB,  WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 45
46: ["DOOR_STEEL",            FLOOR_SLAB, BITMASK_DOOR1,         TAB_NONE,      WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 46
47: ["DOOR_STEEL2",           FLOOR_SLAB, BITMASK_DOOR2,         TAB_MAINSLAB,  WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 47
48: ["DOOR_MAGIC",            FLOOR_SLAB, BITMASK_DOOR1,         TAB_NONE,      WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 48
49: ["DOOR_MAGIC2",           FLOOR_SLAB, BITMASK_DOOR2,         TAB_MAINSLAB,  WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 49
50: ["SLAB50",                FLOOR_SLAB, BITMASK_SIMPLE,        TAB_OTHER,     WIBBLE_OFF,      REMEMBER_PATH,  OWNABLE], # 50
51: ["BRIDGE_FRAME",          FLOOR_SLAB, BITMASK_SIMPLE,        TAB_MAINSLAB,  WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 51
52: ["GEMS",                  BLOCK_SLAB, BITMASK_SIMPLE,        TAB_MAINSLAB,  WIBBLE_ON,       REMEMBER_PATH,  NOT_OWNABLE], # 52
53: ["GUARD_AREA",            FLOOR_SLAB, BITMASK_SIMPLE,        TAB_MAINSLAB,  WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 53
54: ["PURPLE_PATH",           FLOOR_SLAB, BITMASK_SIMPLE,        TAB_OTHER,     WIBBLE_OFF,      REMEMBER_PATH,  NOT_OWNABLE], # 54
999: ["AUTOMATIC_WALL",       BLOCK_SLAB, BITMASK_REINFORCED,    TAB_MAINSLAB,  WIBBLE_ON,       REMEMBER_PATH,  OWNABLE], # 999
}


var icons = {
"BARRACK_AREA": preload("res://dk_images/room_64/armory_std.png"),
"BRIDGE_FRAME": preload("res://dk_images/room_64/bridge_std.png"),
"GRAVE_AREA": preload("res://dk_images/room_64/graveyard_std.png"),
"GUARD_AREA": preload("res://dk_images/room_64/grdpost_std.png"),
"HATCHERY": preload("res://dk_images/room_64/hatchery_std.png"),
"LAIR_AREA": preload("res://dk_images/room_64/lair_std.png"),
"PRISON_AREA": preload("res://dk_images/room_64/prison_std.png"),
"BOOK_SHELVES": preload("res://dk_images/room_64/research_std.png"),
"SCAVENGE_AREA": preload("res://dk_images/room_64/scavenge_std.png"),
"TEMPLE_POOL": preload("res://dk_images/room_64/temple_std.png"),
"TORTURE_AREA": preload("res://dk_images/room_64/torture_std.png"),
"TRAINING_AREA": preload("res://dk_images/room_64/training_std.png"),
"TREASURY_AREA": preload("res://dk_images/room_64/treasury_std.png"),
"WORKSHOP_AREA": preload("res://dk_images/room_64/workshop_std.png"),
"DOOR_WOODEN2": preload("res://dk_images/trapdoor_64/door_pers_wood_std.png"),
"DOOR_BRACE2": preload("res://dk_images/trapdoor_64/door_pers_braced_std.png"),
"DOOR_STEEL2": preload("res://dk_images/trapdoor_64/door_pers_iron_std.png"),
"DOOR_MAGIC2": preload("res://dk_images/trapdoor_64/door_pers_magic_std.png"),
"HEART_PEDESTAL": preload("res://dk_images/crucials/anim0949/r1frame01.png"),
"DOOR_SECRET": preload("res://extra_images/secret_door.png"),
"DOOR_SECRET2": preload("res://extra_images/secret_door.png"),
"DOOR_MIDAS": preload("res://extra_images/midas_door.png"),
"DOOR_MIDAS2": preload("res://extra_images/midas_door.png"),
}

var slabOrder = [
EARTH,
ROCK,
PATH,
CLAIMED_GROUND,
WALL_AUTOMATIC,
GOLD,
GEMS,
WATER,
LAVA,
TREASURE_ROOM,
LAIR,
HATCHERY,
TRAINING_ROOM,
LIBRARY,
BRIDGE,
GUARD_POST,
WORKSHOP,
PRISON,
TORTURE_CHAMBER,
BARRACKS,
TEMPLE,
GRAVEYARD,
SCAVENGER_ROOM,
WOODEN_DOOR_2,
BRACED_DOOR_2,
IRON_DOOR_2,
MAGIC_DOOR_2,
PORTAL,
DUNGEON_HEART,
EARTH_WITH_TORCH,
WALL_WITH_TORCH,
WALL_WITH_BANNER,
WALL_WITH_TWINS,
WALL_WITH_WOMAN,
WALL_WITH_PAIR,
WALL_UNDECORATED,
TREASURE_ROOM_WALL,
LAIR_WALL,
HATCHERY_WALL,
TRAINING_ROOM_WALL,
LIBRARY_WALL,
WORKSHOP_WALL,
PRISON_WALL,
TORTURE_CHAMBER_WALL,
BARRACKS_WALL,
TEMPLE_WALL,
GRAVEYARD_WALL,
SCAVENGER_ROOM_WALL,
PORTAL_WALL,
DUNGEON_HEART_WALL,
SLAB_50,
PURPLE_PATH,
# Unlisted, these are different orientation doors
# WOODEN_DOOR_1
# BRACED_DOOR_1
# IRON_DOOR_1
# MAGIC_DOOR_1
]

func is_door(slabID):
	if data.has(slabID) == true:
		if data[slabID][BITMASK_TYPE] == BITMASK_DOOR1 or data[slabID][BITMASK_TYPE] == BITMASK_DOOR2:
			return true
	return false
