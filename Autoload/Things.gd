extends Node2D

const THING_LIMIT = -1
const ACTION_POINT_LIMIT = -1 #255
const CREATURE_LIMIT = -1 #255
const LIGHT_LIMIT = -1

enum {
	NAME_ID = 0
	SPRITE = 1
	GENRE = 2
}

enum TYPE {
	NONE = 0
	OBJECT = 1
	SHOT = 2
	EFFECTELEM = 3
	DEADCREATURE = 4
	CREATURE = 5
	EFFECT = 6
	EFFECTGEN = 7
	TRAP = 8
	DOOR = 9
	UNKN10 = 10
	UNKN11 = 11
	AMBIENTSND = 12
	CAVEIN = 13
	EXTRA = 696969
}

var default_data = {}
func _init():
	# This only takes 1ms
	default_data["DATA_EXTRA"] = DATA_EXTRA.duplicate(true)
	default_data["DATA_DOOR"] = DATA_DOOR.duplicate(true)
	default_data["DATA_TRAP"] = DATA_TRAP.duplicate(true)
	default_data["DATA_EFFECTGEN"] = DATA_EFFECTGEN.duplicate(true)
	default_data["DATA_CREATURE"] = DATA_CREATURE.duplicate(true)
	default_data["DATA_OBJECT"] = DATA_OBJECT.duplicate(true)
	default_data["LIST_OF_BOXES"] = LIST_OF_BOXES.duplicate(true)

func reset_thing_data_to_default(): # Reset data. Takes 1ms.
	DATA_EXTRA = default_data["DATA_EXTRA"].duplicate(true)
	DATA_DOOR = default_data["DATA_DOOR"].duplicate(true)
	DATA_TRAP = default_data["DATA_TRAP"].duplicate(true)
	DATA_EFFECTGEN = default_data["DATA_EFFECTGEN"].duplicate(true)
	DATA_CREATURE = default_data["DATA_CREATURE"].duplicate(true)
	DATA_OBJECT = default_data["DATA_OBJECT"].duplicate(true)
	LIST_OF_BOXES = default_data["LIST_OF_BOXES"].duplicate(true)

func fetch_sprite(thing_type:int, sub_type:int):
	var data_structure_dictionary = data_structure(thing_type)
	var sub_type_data = data_structure_dictionary.get(sub_type)
	if sub_type_data:
		var sprite = Graphics.sprite_id.get(sub_type_data[SPRITE])
		if sprite:
			return sprite
		if sub_type_data.size() >= 3:
			match sub_type_data[GENRE]:
				"SPECIALBOX":  return Graphics.sprite_id.get(901, null)
				"SPELLBOOK":   return Graphics.sprite_id.get(777, null)
				"WORKSHOPBOX": return Graphics.sprite_id.get(114, null)
	return null


func fetch_portrait(thing_type, sub_type):
	var sub_type_data = data_structure(thing_type).get(sub_type)
	if sub_type_data:
		var sprID = sub_type_data[SPRITE]
		var asdf = str(sprID) + "_PORTRAIT"
		return Graphics.sprite_id.get(asdf, null)
	return null


func fetch_name(thing_type, sub_type):
	var dictionary_of_names = Names.things.get(thing_type)
	if dictionary_of_names:
		var data_structure = data_structure(thing_type)
		var sub_type_data = data_structure.get(sub_type)
		if sub_type_data:
			var nameId = sub_type_data[NAME_ID]
			if nameId is String:
				return dictionary_of_names.get(nameId, nameId.capitalize())
			elif nameId is Array: # This is to take into considersation someone accidentally using two words with spaces as an object name. (otherwise we get a crash)
				return dictionary_of_names.get(nameId[0], nameId[0].capitalize())
			return "Error1337"
		else:
			return "Unknown " + data_structure_name[thing_type] + ": " + str(sub_type)
	else:
		return "Unknown Thingtype " + str(thing_type) + ", Subtype: " + str(sub_type)

func fetch_id_string(thing_type, sub_type):
	var data_structure = data_structure(thing_type)
	var sub_type_data = data_structure.get(sub_type)
	if sub_type_data:
		var nameId = sub_type_data[NAME_ID]
		if nameId is String:
			return nameId
		elif nameId is Array: # This is to take into considersation someone accidentally using two words with spaces as an object name. (otherwise we get a crash)
			return nameId[0].capitalize()
		return "Error1337"
	else:
		return "Unknown " + data_structure_name.get(thing_type, "Unknown") + ": " + str(sub_type)


var data_structure_name = {
	TYPE.NONE: "Empty",
	TYPE.OBJECT: "Object",
	TYPE.SHOT: "Shot",
	TYPE.EFFECTELEM: "EffectElem",
	TYPE.DEADCREATURE: "DeadCreature",
	TYPE.CREATURE: "Creature",
	TYPE.EFFECT: "Effect",
	TYPE.EFFECTGEN: "EffectGen",
	TYPE.TRAP: "Trap",
	TYPE.DOOR: "Door",
	TYPE.UNKN10: "Unkn10",
	TYPE.UNKN11: "Unkn11",
	TYPE.AMBIENTSND: "AmbientSnd",
	TYPE.CAVEIN: "CaveIn",
	TYPE.EXTRA: "Extra"
}


var reverse_data_structure_name = {
	"Empty": TYPE.NONE,
	"Object":TYPE.OBJECT,
	"Shot":TYPE.SHOT,
	"EffectElem":TYPE.EFFECTELEM,
	"DeadCreature":TYPE.DEADCREATURE,
	"Creature":TYPE.CREATURE,
	"Effect":TYPE.EFFECT,
	"EffectGen":TYPE.EFFECTGEN,
	"Trap":TYPE.TRAP,
	"Door":TYPE.DOOR,
	"Unkn10":TYPE.UNKN10,
	"Unkn11":TYPE.UNKN11,
	"AmbientSnd":TYPE.AMBIENTSND,
	"CaveIn":TYPE.CAVEIN,
	"Extra":TYPE.EXTRA,
}

func data_structure(thingType:int):
	match thingType:
		Things.TYPE.OBJECT: return DATA_OBJECT
		Things.TYPE.CREATURE: return DATA_CREATURE
		Things.TYPE.EFFECTGEN: return DATA_EFFECTGEN
		Things.TYPE.TRAP: return DATA_TRAP
		Things.TYPE.DOOR: return DATA_DOOR
		Things.TYPE.EXTRA: return DATA_EXTRA
	print("This should never happen.")
	return {}


var LIST_OF_BOXES = {
"WRKBOX_BOULDER" : [TYPE.TRAP, 1],
"WRKBOX_ALARM" : [TYPE.TRAP, 2],
"WRKBOX_POISONG" : [TYPE.TRAP, 3],
"WRKBOX_LIGHTNG" : [TYPE.TRAP, 4],
"WRKBOX_WRDOFPW" : [TYPE.TRAP, 5],
"WRKBOX_LAVA" : [TYPE.TRAP, 6],
"WRKBOX_WOOD" : [TYPE.DOOR, 1],
"WRKBOX_BRACE" : [TYPE.DOOR, 2],
"WRKBOX_STEEL" : [TYPE.DOOR, 3],
"WRKBOX_MAGIC" : [TYPE.DOOR, 4],
}



var LIST_OF_GOLDPILES = [
	3, 6, 43, 128, 136
]
var LIST_OF_SPELLBOOKS = [ ]
var LIST_OF_HEROGATES = [ ]

func clear_dynamic_lists():
	LIST_OF_SPELLBOOKS.clear()
	LIST_OF_HEROGATES.clear()

enum SPELLBOOK {
	HAND = 11
	SLAP = 14
	POSSESS = 135
	IMP = 12
	SIGHT = 15
	SPEED = 21
	OBEY = 13
	CALL_TO_ARMS = 16
	CONCEAL = 23
	HOLD_AUDIENCE = 19
	CAVE_IN = 17
	HEAL_CREATURE = 18
	LIGHTNING = 20
	PROTECT = 22
	CHICKEN = 46
	DISEASE = 45
	ARMAGEDDON = 134
	DESTROY_WALLS = 47
}

var collectible_belonging = {
	"VALUABLE" : Slabs.TREASURE_ROOM,
	"SPELLBOOK" : Slabs.LIBRARY,
	"SPECIALBOX" : Slabs.LIBRARY,
	"WORKSHOPBOX" : Slabs.WORKSHOP,
}

func convert_relative_256_to_float(datnum):
	if datnum >= 32768: # If the sign bit is set (indicating a negative value)
		datnum -= 65536 # Convert to signed by subtracting 2^16
	return datnum / 256.0 # Scale it to floating-point


func find_subtype_by_name(thingType, findName):
	var data = data_structure(thingType)
	for subtype_key in data:
		var subtype_data = data[subtype_key]
		if subtype_data and subtype_data[NAME_ID] == findName:
			return subtype_key
	return null

func is_custom_special_box(subtype):
	if not DATA_OBJECT.has(subtype) or DATA_OBJECT[subtype][GENRE] != "SPECIALBOX":
		return false
	if subtype in [86,87,88,89,90,91,92,93,170,171,172,173]:
		return false
	return true

var DATA_EXTRA = {
0 : [null, null, null, null],
1 : ["ACTIONPOINT", "ACTIONPOINT"],
2 : ["LIGHT", "LIGHT"],
}

var DATA_DOOR = { #
0 : [null, null, null],
1 : ["WOOD", "WOOD"],
2 : ["BRACED", "BRACED"],
3 : ["STEEL", "STEEL"],
4 : ["MAGIC", "MAGIC"]
}

var DATA_TRAP = {
00 : [null, null, null],
01 : ["BOULDER", "BOULDER"],
02 : ["ALARM", "ALARM"],
03 : ["POISON_GAS", "POISON_GAS"],
04 : ["LIGHTNING", "LIGHTNING"],
05 : ["WORD_OF_POWER", "WORD_OF_POWER"],
06 : ["LAVA", "LAVA"],
}

var DATA_EFFECTGEN = {
0 : [null, null, null],
1 : ["EFFECTGENERATOR_LAVA", "EFFECTGENERATOR_LAVA"],
2 : ["EFFECTGENERATOR_DRIPPING_WATER", "EFFECTGENERATOR_DRIPPING_WATER"],
3 : ["EFFECTGENERATOR_ROCK_FALL", "EFFECTGENERATOR_ROCK_FALL"],
4 : ["EFFECTGENERATOR_ENTRANCE_ICE", "EFFECTGENERATOR_ENTRANCE_ICE"],
5 : ["EFFECTGENERATOR_DRY_ICE", "EFFECTGENERATOR_DRY_ICE"]
}

var DATA_CREATURE = {
00 : [null, null, null],
01 : ["WIZARD",          "WIZARD"],
02 : ["BARBARIAN",       "BARBARIAN"],
03 : ["ARCHER",          "ARCHER"],
04 : ["MONK",            "MONK"],
05 : ["DWARFA",          "DWARFA"],
06 : ["KNIGHT",          "KNIGHT"],
07 : ["AVATAR",          "AVATAR"],
08 : ["TUNNELLER",       "TUNNELLER"],
09 : ["WITCH",           "WITCH"],
10 : ["GIANT",           "GIANT"],
11 : ["FAIRY",           "FAIRY"],
12 : ["THIEF",           "THIEF"],
13 : ["SAMURAI",         "SAMURAI"],
14 : ["HORNY",           "HORNY"],
15 : ["SKELETON",        "SKELETON"],
16 : ["TROLL",           "TROLL"],
17 : ["DRAGON",          "DRAGON"],
18 : ["DEMONSPAWN",      "DEMONSPAWN"],
19 : ["FLY",             "FLY"],
20 : ["DARK_MISTRESS",   "DARK_MISTRESS"],
21 : ["SORCEROR",        "SORCEROR"],
22 : ["BILE_DEMON",      "BILE_DEMON"],
23 : ["IMP",             "IMP"],
24 : ["BUG",             "BUG"],
25 : ["VAMPIRE",         "VAMPIRE"],
26 : ["SPIDER",          "SPIDER"],
27 : ["HELL_HOUND",      "HELL_HOUND"],
28 : ["GHOST",           "GHOST"],
29 : ["TENTACLE",        "TENTACLE"],
30 : ["ORC",             "ORC"],
31 : ["FLOATING_SPIRIT", "FLOATING_SPIRIT"],
}

var DATA_OBJECT = {
000 : [null, null, null],
001 : ["BARREL", 930, "DECORATION"],
002 : ["TORCH", 962, "FURNITURE"],
003 : ["GOLD_CHEST", 934, "VALUABLE"],
004 : ["TEMPLE_STATUE", 950, "FURNITURE"],
005 : ["SOUL_CONTAINER", 948, "FURNITURE"],
006 : ["GOLD", 934, "VALUABLE"],
007 : ["TORCHUN", 962, "FURNITURE"],
008 : ["STATUEWO", 950, "DECORATION"],
009 : ["CHICKEN_GRW", 893, "FURNITURE"],
010 : ["CHICKEN_MAT", 819, "FOOD"],
011 : ["SPELLBOOK_HOE", "SPELLBOOK_HOE", "SPELLBOOK"],
012 : ["SPELLBOOK_IMP", "SPELLBOOK_IMP", "SPELLBOOK"],
013 : ["SPELLBOOK_OBEY", "SPELLBOOK_OBEY", "SPELLBOOK"],
014 : ["SPELLBOOK_SLAP", "SPELLBOOK_SLAP", "SPELLBOOK"],
015 : ["SPELLBOOK_SOE", "SPELLBOOK_SOE", "SPELLBOOK"],
016 : ["SPELLBOOK_CTA", "SPELLBOOK_CTA", "SPELLBOOK"],
017 : ["SPELLBOOK_CAVI", "SPELLBOOK_CAVI", "SPELLBOOK"],
018 : ["SPELLBOOK_HEAL", "SPELLBOOK_HEAL", "SPELLBOOK"],
019 : ["SPELLBOOK_HLDAUD", "SPELLBOOK_HLDAUD", "SPELLBOOK"],
020 : ["SPELLBOOK_LIGHTN", "SPELLBOOK_LIGHTN", "SPELLBOOK"],
021 : ["SPELLBOOK_SPDC", "SPELLBOOK_SPDC", "SPELLBOOK"],
022 : ["SPELLBOOK_PROT", "SPELLBOOK_PROT", "SPELLBOOK"],
023 : ["SPELLBOOK_CONCL", "SPELLBOOK_CONCL", "SPELLBOOK"],
024 : ["CTA_ENSIGN", null, "POWER"],
025 : ["ROOM_FLAG", null, "DECORATION"],
026 : ["ANVIL", 789, "FURNITURE"],
027 : ["PRISON_BAR", 796, "FURNITURE"],
028 : ["CANDLESTCK", 791, "FURNITURE"],
029 : ["GRAVE_STONE", 793, "FURNITURE"],
030 : ["STATUE_HORNY", 905, "FURNITURE"],
031 : ["TRAINING_POST", 795, "FURNITURE"],
032 : ["TORTURE_SPIKE", 892, "FURNITURE"],
033 : ["TEMPLE_SPANGLE", 797, "FURNITURE"],
034 : ["POTION_PURPLE", 804, "DECORATION"],
035 : ["POTION_BLUE", 806, "DECORATION"],
036 : ["POTION_GREEN", 808, "DECORATION"],
037 : ["POWER_HAND", 782, "POWER"],
038 : ["POWER_HAND_GRAB", 783, "POWER"],
039 : ["POWER_HAND_WHIP", 785, "POWER"],
040 : ["CHICKEN_STB", 894, "FURNITURE"],
041 : ["CHICKEN_WOB", 895, "FURNITURE"],
042 : ["CHICKEN_CRK", 896, "FURNITURE"],
043 : ["GOLDL", 936, "VALUABLE"],
044 : ["SPINNING_KEY", 810, "FURNITURE"],
045 : ["SPELLBOOK_DISEASE", "SPELLBOOK_DISEASE", "SPELLBOOK"],
046 : ["SPELLBOOK_CHKN", "SPELLBOOK_CHKN", "SPELLBOOK"],
047 : ["SPELLBOOK_DWAL", "SPELLBOOK_DWAL", "SPELLBOOK"],
048 : ["SPELLBOOK_TBMB", "SPELLBOOK_TBMB", "SPELLBOOK"],
049 : ["HERO_GATE", 776, "HEROGATE"],
050 : ["SPINNING_KEY2", 810, "EFFECT"],
051 : ["ARMOUR", null, "EFFECT"],
052 : ["GOLD_HOARD_1", 936, "TREASURE_HOARD"],
053 : ["GOLD_HOARD_2", 937, "TREASURE_HOARD"],
054 : ["GOLD_HOARD_3", 938, "TREASURE_HOARD"],
055 : ["GOLD_HOARD_4", 939, "TREASURE_HOARD"],
056 : ["GOLD_HOARD_5", 940, "TREASURE_HOARD"],
057 : ["LAIR_WIZRD", 124, "LAIR_TOTEM"],
058 : ["LAIR_BARBR", 124, "LAIR_TOTEM"],
059 : ["LAIR_ARCHR", 124, "LAIR_TOTEM"],
060 : ["LAIR_MONK", 124, "LAIR_TOTEM"],
061 : ["LAIR_DWRFA", 124, "LAIR_TOTEM"],
062 : ["LAIR_KNGHT", 124, "LAIR_TOTEM"],
063 : ["LAIR_AVATR", 124, "LAIR_TOTEM"],
064 : ["LAIR_TUNLR", 124, "LAIR_TOTEM"],
065 : ["LAIR_WITCH", 124, "LAIR_TOTEM"],
066 : ["LAIR_GIANT", 124, "LAIR_TOTEM"],
067 : ["LAIR_FAIRY", 124, "LAIR_TOTEM"],
068 : ["LAIR_THIEF", 124, "LAIR_TOTEM"],
069 : ["LAIR_SAMUR", 124, "LAIR_TOTEM"],
070 : ["LAIR_HORNY", 158, "LAIR_TOTEM"],
071 : ["LAIR_SKELT", 156, "LAIR_TOTEM"],
072 : ["LAIR_GOBLN", 154, "LAIR_TOTEM"],
073 : ["LAIR_DRAGN", 152, "LAIR_TOTEM"],
074 : ["LAIR_DEMSP", 150, "LAIR_TOTEM"],
075 : ["LAIR_FLY", 148, "LAIR_TOTEM"],
076 : ["LAIR_DKMIS", 146, "LAIR_TOTEM"],
077 : ["LAIR_SORCR", 144, "LAIR_TOTEM"],
078 : ["LAIR_BILDM", 142, "LAIR_TOTEM"],
079 : ["LAIR_IMP", 152, "LAIR_TOTEM"],
080 : ["LAIR_BUG", 140, "LAIR_TOTEM"],
081 : ["LAIR_VAMP", 138, "LAIR_TOTEM"],
082 : ["LAIR_SPIDR", 136, "LAIR_TOTEM"],
083 : ["LAIR_HLHND", 134, "LAIR_TOTEM"],
084 : ["LAIR_GHOST", 132, "LAIR_TOTEM"],
085 : ["LAIR_TENTC", 128, "LAIR_TOTEM"],
086 : ["SPECBOX_REVMAP", 901, "SPECIALBOX"],
087 : ["SPECBOX_RESURCT", 901, "SPECIALBOX"],
088 : ["SPECBOX_TRANSFR", 901, "SPECIALBOX"],
089 : ["SPECBOX_STEALHR", 901, "SPECIALBOX"],
090 : ["SPECBOX_MULTPLY", 901, "SPECIALBOX"],
091 : ["SPECBOX_INCLEV", 901, "SPECIALBOX"],
092 : ["SPECBOX_MKSAFE", 901, "SPECIALBOX"],
093 : ["SPECBOX_HIDNWRL", 901, "SPECIALBOX"],
094 : ["WRKBOX_BOULDER", 114, "WORKSHOPBOX"],
095 : ["WRKBOX_ALARM", 114, "WORKSHOPBOX"],
096 : ["WRKBOX_POISONG", 114, "WORKSHOPBOX"],
097 : ["WRKBOX_LIGHTNG", 114, "WORKSHOPBOX"],
098 : ["WRKBOX_WRDOFPW", 114, "WORKSHOPBOX"],
099 : ["WRKBOX_LAVA", 114, "WORKSHOPBOX"],
100 : ["WRKBOX_DEMOLTN", 114, "WORKSHOPBOX"],
101 : ["WRKBOX_DUMMY3", 114, "WORKSHOPBOX"],
102 : ["WRKBOX_DUMMY4", 114, "WORKSHOPBOX"],
103 : ["WRKBOX_DUMMY5", 114, "WORKSHOPBOX"],
104 : ["WRKBOX_DUMMY6", 114, "WORKSHOPBOX"],
105 : ["WRKBOX_DUMMY7", 114, "WORKSHOPBOX"],
106 : ["WRKBOX_WOOD", 114, "WORKSHOPBOX"],
107 : ["WRKBOX_BRACE", 114, "WORKSHOPBOX"],
108 : ["WRKBOX_STEEL", 114, "WORKSHOPBOX"],
109 : ["WRKBOX_MAGIC", 114, "WORKSHOPBOX"],
110 : ["WRKBOX_ITEM", 789, "WORKSHOPBOX"],
111 : ["HEARTFLAME_RED", 798, "FURNITURE"],
112 : ["DISEASE", null, "EFFECT"],
113 : ["SCAVENGE_EYE", 130, "FURNITURE"],
114 : ["WORKSHOP_MACHINE", 98, "FURNITURE"],
115 : ["GUARDFLAG_RED", 102, "FURNITURE"],
116 : ["GUARDFLAG_BLUE", 104, "FURNITURE"],
117 : ["GUARDFLAG_GREEN", 106, "FURNITURE"],
118 : ["GUARDFLAG_YELLOW", 108, "FURNITURE"],
119 : ["FLAG_POST", 100, "FURNITURE"],
120 : ["HEARTFLAME_BLUE", 799, "FURNITURE"],
121 : ["HEARTFLAME_GREEN", 800, "FURNITURE"],
122 : ["HEARTFLAME_YELLOW", 801, "FURNITURE"],
123 : ["POWER_SIGHT", "POWER_SIGHT", "POWER"],
124 : ["POWER_LIGHTNG", null, "POWER"],
125 : ["TORTURER", 46, "FURNITURE"],
126 : ["LAIR_ORC", 126, "LAIR_TOTEM"],
127 : ["POWER_HAND_GOLD", 781, "POWER"],
128 : ["SPINNCOIN", null, "EFFECT"],
129 : ["STATUE2", 952, "DECORATION"],
130 : ["STATUE3", "GOLDEN_ARMOR", "DECORATION"],
131 : ["STATUE4", "KNIGHTSTATUE", "DECORATION"],
132 : ["STATUE5", 958, "DECORATION"],
133 : ["SPECBOX_CUSTOM", 901, "SPECIALBOX"],
134 : ["SPELLBOOK_ARMG", "SPELLBOOK_ARMG", "SPELLBOOK"],
135 : ["SPELLBOOK_POSS", "SPELLBOOK_POSS", "SPELLBOOK"],
}
