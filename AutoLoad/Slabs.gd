extends Node

# Slabs.array[grid_value][parameter]

# DISPLAYS DECORATION STUFF ON THE SIDE

enum {
	BITMASK_GENERAL
	BITMASK_WALL
	BITMASK_TALL
	BITMASK_OTHER
	BITMASK_CLAIMED
}

enum {
	NAME
	IS_SOLID # Whether units can walk there, and how fortified walls do their bitmask, AND for 3D generation optimization
	BITMASK_TYPE
	PANEL_VIEW
	SIDE_VIEW_Z_OFFSET
	EDITOR_TAB
	WIBBLE_TYPE
	REMEMBER_TYPE
	IS_OWNABLE
}
enum {
	REMEMBER_PATH
	REMEMBER_LAVA
	REMEMBER_WATER
}
enum {
	WIBBLE_OFF
	WIBBLE_ON
	WIBBLE_ANIMATED
}
enum {
	TAB_MAINSLAB
	TAB_OTHER
	TAB_CUSTOM
	TAB_STYLE
	TAB_OWNER
	TAB_NONE
}
const OWNABLE = true
const NOT_OWNABLE = false
const BLOCK_SLAB = true
const FLOOR_SLAB = false

enum {
	PANEL_TOP_VIEW
	PANEL_SIDE_VIEW
	PANEL_DOOR_VIEW
}

var auto_wall_updates_these = {
	WALL_WITH_BANNER:null,
	WALL_WITH_TORCH:null,
	WALL_WITH_TWINS:null,
	WALL_WITH_WOMAN:null,
	WALL_WITH_PAIR:null,
	WALL_DAMAGED:null,
	WALL_AUTOMATIC:null,
}

var rooms_with_middle_slab = {
	LIBRARY:null,
	TEMPLE:null,
	BARRACKS:null,
	DUNGEON_HEART:null,
}
var rooms_with_middle_object = {
	SCAVENGER_ROOM:null,
	WORKSHOP:null,
	TRAINING_ROOM:null,
	TORTURE_CHAMBER:null,
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
	WALL_DAMAGED = 9,
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
#	PURPLE_PATH2 = 55,
#	PURPLE_PATH3 = 56,
#	PURPLE_PATH4 = 57,
	# 58 doesn't exist within 1304 entries
	WALL_AUTOMATIC = 999,
}

var rooms = {14:null,16:null,18:null,20:null,22:null,24:null,26:null,28:null,30:null,32:null,34:null,36:null,38:null,40:null}
var doors = {42:null,43:null,44:null,45:null,46:null,47:null,48:null,49:null}
#var walls = [
#	4,5,6,7,8,9
#]

func _init():
	#var CODETIME_START = OS.get_ticks_msec()
	# Fill empty entries to prevent crashes, takes 0ms
	
	for i in 2000:
		if data.has(i) == false:
			data[i] = data[-1]
	#print('Codetime: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')

var data = {
	-1:                  ["Unknown",               BLOCK_SLAB, BITMASK_TALL, PANEL_TOP_VIEW,  0, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # -1
	ROCK:                ["Impenetrable Rock",     BLOCK_SLAB, BITMASK_TALL, PANEL_TOP_VIEW,  0, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   NOT_OWNABLE], # 0
	GOLD:                ["Gold Seam",             BLOCK_SLAB, BITMASK_TALL,    PANEL_TOP_VIEW,  0, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   NOT_OWNABLE], # 1
	EARTH:               ["Earth",                 BLOCK_SLAB, BITMASK_TALL, PANEL_TOP_VIEW,  0, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   NOT_OWNABLE], # 2
	EARTH_WITH_TORCH:    ["Torch Earth",           BLOCK_SLAB, BITMASK_TALL, PANEL_SIDE_VIEW, 4, TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,   NOT_OWNABLE], # 3
	WALL_WITH_BANNER:    ["Banner Wall",           BLOCK_SLAB, BITMASK_WALL,    PANEL_SIDE_VIEW, 4, TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 4
	WALL_WITH_TORCH:     ["Torch Wall",            BLOCK_SLAB, BITMASK_WALL,    PANEL_SIDE_VIEW, 4, TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 5
	WALL_WITH_TWINS:     ["Twins Wall",            BLOCK_SLAB, BITMASK_WALL,    PANEL_SIDE_VIEW, 4, TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 6
	WALL_WITH_WOMAN:     ["Woman Wall",            BLOCK_SLAB, BITMASK_WALL,    PANEL_SIDE_VIEW, 4, TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 7
	WALL_WITH_PAIR:      ["Pair Wall",             BLOCK_SLAB, BITMASK_WALL,    PANEL_SIDE_VIEW, 4, TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 8
	WALL_DAMAGED:        ["Damaged Wall",          BLOCK_SLAB, BITMASK_WALL,    PANEL_SIDE_VIEW, 4, TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 9
	PATH:                ["Dirt Path",             FLOOR_SLAB, BITMASK_GENERAL, PANEL_TOP_VIEW,  0, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   NOT_OWNABLE], # 10
	CLAIMED_GROUND:      ["Claimed Area",          FLOOR_SLAB, BITMASK_CLAIMED, PANEL_TOP_VIEW,  0, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 11
	LAVA:                ["Lava",                  FLOOR_SLAB, BITMASK_GENERAL,    PANEL_TOP_VIEW,  0, TAB_MAINSLAB, WIBBLE_ANIMATED, REMEMBER_LAVA,  NOT_OWNABLE], # 12
	WATER:               ["Water",                 FLOOR_SLAB, BITMASK_GENERAL,    PANEL_TOP_VIEW,  0, TAB_MAINSLAB, WIBBLE_ANIMATED, REMEMBER_WATER, NOT_OWNABLE], # 13
	PORTAL:              ["Portal",                FLOOR_SLAB, BITMASK_GENERAL, PANEL_TOP_VIEW,  0, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 14
	PORTAL_WALL:         ["Portal Wall",           BLOCK_SLAB, BITMASK_WALL,    PANEL_SIDE_VIEW, 3, TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 15
	TREASURE_ROOM:       ["Treasure Room",         FLOOR_SLAB, BITMASK_GENERAL, PANEL_TOP_VIEW,  0, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 16
	TREASURE_ROOM_WALL:  ["Treasure Room Wall",    BLOCK_SLAB, BITMASK_WALL,    PANEL_SIDE_VIEW, 3, TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 17
	LIBRARY:             ["Library",               FLOOR_SLAB, BITMASK_GENERAL, PANEL_TOP_VIEW,  0, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 18
	LIBRARY_WALL:        ["Library Wall",          BLOCK_SLAB, BITMASK_WALL,    PANEL_SIDE_VIEW, 3, TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 19
	PRISON:              ["Prison",                FLOOR_SLAB, BITMASK_GENERAL, PANEL_TOP_VIEW,  0, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 20
	PRISON_WALL:         ["Prison Wall",           BLOCK_SLAB, BITMASK_WALL,    PANEL_SIDE_VIEW, 3, TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 21
	TORTURE_CHAMBER:     ["Torture Chamber",       FLOOR_SLAB, BITMASK_GENERAL, PANEL_TOP_VIEW,  0, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 22
	TORTURE_CHAMBER_WALL:["Torture Chamber Wall",  BLOCK_SLAB, BITMASK_WALL,    PANEL_SIDE_VIEW, 4, TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 23
	TRAINING_ROOM:       ["Training Room",         FLOOR_SLAB, BITMASK_GENERAL, PANEL_TOP_VIEW,  3, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 24
	TRAINING_ROOM_WALL:  ["Training Room Wall",    BLOCK_SLAB, BITMASK_WALL,    PANEL_SIDE_VIEW, 3, TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 25
	DUNGEON_HEART:       ["Heart Room",            FLOOR_SLAB, BITMASK_GENERAL, PANEL_TOP_VIEW,  0, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 26
	DUNGEON_HEART_WALL:  ["Heart Room Wall",       BLOCK_SLAB, BITMASK_WALL,    PANEL_SIDE_VIEW, 3, TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 27
	WORKSHOP:            ["Workshop",              FLOOR_SLAB, BITMASK_GENERAL, PANEL_TOP_VIEW,  0, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 28
	WORKSHOP_WALL:       ["Workshop Wall",         BLOCK_SLAB, BITMASK_WALL,    PANEL_SIDE_VIEW, 3, TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 29
	SCAVENGER_ROOM:      ["Scavenger Room",        FLOOR_SLAB, BITMASK_GENERAL, PANEL_TOP_VIEW,  0, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 30
	SCAVENGER_ROOM_WALL: ["Scavenger Room Wall",   BLOCK_SLAB, BITMASK_WALL,    PANEL_SIDE_VIEW, 3, TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 31
	TEMPLE:              ["Temple",                FLOOR_SLAB, BITMASK_GENERAL, PANEL_TOP_VIEW,  0, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 32
	TEMPLE_WALL:         ["Temple Wall",           BLOCK_SLAB, BITMASK_WALL,    PANEL_SIDE_VIEW, 3, TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 33
	GRAVEYARD:           ["Graveyard",             FLOOR_SLAB, BITMASK_GENERAL, PANEL_TOP_VIEW,  0, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 34
	GRAVEYARD_WALL:      ["Graveyard Wall",        BLOCK_SLAB, BITMASK_WALL,    PANEL_SIDE_VIEW, 3, TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 35
	HATCHERY:            ["Hatchery",              FLOOR_SLAB, BITMASK_GENERAL, PANEL_TOP_VIEW,  0, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 36
	HATCHERY_WALL:       ["Hatchery Wall",         BLOCK_SLAB, BITMASK_WALL,    PANEL_SIDE_VIEW, 3, TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 37
	LAIR:                ["Lair",                  FLOOR_SLAB, BITMASK_GENERAL, PANEL_TOP_VIEW,  0, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 38
	LAIR_WALL:           ["Lair Wall",             BLOCK_SLAB, BITMASK_WALL,    PANEL_SIDE_VIEW, 3, TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 39
	BARRACKS:            ["Barracks",              FLOOR_SLAB, BITMASK_GENERAL, PANEL_TOP_VIEW,  0, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 40
	BARRACKS_WALL:       ["Barracks Wall",         BLOCK_SLAB, BITMASK_WALL,    PANEL_SIDE_VIEW, 3, TAB_OTHER,     WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 41
	WOODEN_DOOR_1:       ["Wooden Door",           FLOOR_SLAB, BITMASK_OTHER,   PANEL_DOOR_VIEW, 3, TAB_NONE,     WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 42
	WOODEN_DOOR_2:       ["Wooden Door",           FLOOR_SLAB, BITMASK_OTHER,   PANEL_DOOR_VIEW, 3, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 43
	BRACED_DOOR_1:       ["Braced Door",           FLOOR_SLAB, BITMASK_OTHER,   PANEL_DOOR_VIEW, 3, TAB_NONE,     WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 44
	BRACED_DOOR_2:       ["Braced Door",           FLOOR_SLAB, BITMASK_OTHER,   PANEL_DOOR_VIEW, 3, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 45
	IRON_DOOR_1:         ["Iron Door",             FLOOR_SLAB, BITMASK_OTHER,   PANEL_DOOR_VIEW, 3, TAB_NONE,     WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 46
	IRON_DOOR_2:         ["Iron Door",             FLOOR_SLAB, BITMASK_OTHER,   PANEL_DOOR_VIEW, 3, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 47
	MAGIC_DOOR_1:        ["Magic Door",            FLOOR_SLAB, BITMASK_OTHER,   PANEL_DOOR_VIEW, 3, TAB_NONE,     WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 48
	MAGIC_DOOR_2:        ["Magic Door",            FLOOR_SLAB, BITMASK_OTHER,   PANEL_DOOR_VIEW, 3, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 49
	SLAB_50:             ["Slab 50",               FLOOR_SLAB, BITMASK_OTHER,   PANEL_TOP_VIEW,  3, TAB_OTHER, WIBBLE_OFF,      REMEMBER_PATH,   OWNABLE], # 50
	BRIDGE:              ["Bridge",                FLOOR_SLAB, BITMASK_OTHER,   PANEL_TOP_VIEW,  3, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 51
	GEMS:                ["Gems",                  BLOCK_SLAB, BITMASK_OTHER,   PANEL_TOP_VIEW,  3, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   NOT_OWNABLE], # 52
	GUARD_POST:          ["Guard Post",            FLOOR_SLAB, BITMASK_OTHER,   PANEL_TOP_VIEW,  3, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   OWNABLE], # 53
	PURPLE_PATH:         ["Purple Path",           FLOOR_SLAB, BITMASK_OTHER,    PANEL_TOP_VIEW,  0, TAB_OTHER, WIBBLE_OFF,     REMEMBER_PATH,   NOT_OWNABLE], # 54
#	PURPLE_PATH2:        ["Purple Path 2",         FLOOR_SLAB, BITMASK_OTHER,    PANEL_TOP_VIEW,  0, TAB_MAINSLAB, WIBBLE_OFF,      REMEMBER_PATH,   true], # 55
#	PURPLE_PATH3:        ["Purple Path 3",         FLOOR_SLAB, BITMASK_OTHER,    PANEL_TOP_VIEW,  0, TAB_MAINSLAB, WIBBLE_OFF,      REMEMBER_PATH,   true], # 56
#	PURPLE_PATH4:        ["Purple Path 4",         FLOOR_SLAB, BITMASK_OTHER,    PANEL_TOP_VIEW,  0, TAB_MAINSLAB, WIBBLE_OFF,      REMEMBER_PATH,   true], # 57
	WALL_AUTOMATIC:      ["Wall Automatic",        BLOCK_SLAB, BITMASK_WALL,    PANEL_TOP_VIEW,  0, TAB_MAINSLAB, WIBBLE_ON,       REMEMBER_PATH,   true], # 99999
}
var icons = {
	BARRACKS: preload("res://dk_images/room_64/armory_std.png"),
	BRIDGE: preload("res://dk_images/room_64/bridge_std.png"),
	GRAVEYARD: preload("res://dk_images/room_64/graveyard_std.png"),
	GUARD_POST: preload("res://dk_images/room_64/grdpost_std.png"),
	HATCHERY: preload("res://dk_images/room_64/hatchery_std.png"),
	LAIR: preload("res://dk_images/room_64/lair_std.png"),
	PRISON: preload("res://dk_images/room_64/prison_std.png"),
	LIBRARY: preload("res://dk_images/room_64/research_std.png"),
	SCAVENGER_ROOM: preload("res://dk_images/room_64/scavenge_std.png"),
	TEMPLE: preload("res://dk_images/room_64/temple_std.png"),
	TORTURE_CHAMBER: preload("res://dk_images/room_64/torture_std.png"),
	TRAINING_ROOM: preload("res://dk_images/room_64/training_std.png"),
	TREASURE_ROOM: preload("res://dk_images/room_64/treasury_std.png"),
	WORKSHOP: preload("res://dk_images/room_64/workshop_std.png"),
	WOODEN_DOOR_2: preload("res://dk_images/trapdoor_64/door_pers_wood_std.png"),
	BRACED_DOOR_2: preload("res://dk_images/trapdoor_64/door_pers_braced_std.png"),
	IRON_DOOR_2: preload("res://dk_images/trapdoor_64/door_pers_iron_std.png"),
	MAGIC_DOOR_2: preload("res://dk_images/trapdoor_64/door_pers_magic_std.png"),
	DUNGEON_HEART: preload("res://dk_images/crucials/anim0949/r1frame01.png"), 
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

#PURPLE_PATH2,
#PURPLE_PATH3,
#PURPLE_PATH4,

EARTH_WITH_TORCH,
WALL_WITH_TORCH,
WALL_WITH_BANNER,
WALL_WITH_TWINS,
WALL_WITH_WOMAN,
WALL_WITH_PAIR,
WALL_DAMAGED,
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
