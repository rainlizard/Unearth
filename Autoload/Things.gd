extends Node2D

enum {
	NAME_ID = 0
	SPRITE = 1
	PORTRAIT = 2 # Keep PORTAIT field "null" if I want to use texture for portrait.
	EDITOR_TAB = 3
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

const THING_LIMIT = -1#2048
const ACTION_POINT_LIMIT = -1#255
const CREATURE_LIMIT = -1#255
const LIGHT_LIMIT = -1


func fetch_sprite(thing_type, sub_type):
	var sub_type_data = data_structure(thing_type).get(sub_type)
	if sub_type_data:
		var sprite = Graphics.sprite_id.get(sub_type_data[SPRITE])
		if sprite:
			return sprite
		match sub_type_data[EDITOR_TAB]:
			TAB_SPECIAL: return Graphics.sprite_id.get(901, null)
			TAB_SPELL:   return Graphics.sprite_id.get("IMG_BOOK_ICON", null)
			TAB_BOX:     return Graphics.sprite_id.get(114, null)
	return null


func fetch_portrait(thing_type, sub_type):
	var sub_type_data = data_structure(thing_type).get(sub_type)
	if sub_type_data:
		var sprID = sub_type_data[PORTRAIT]
		return Graphics.sprite_id.get(sprID, null)
	return null


func fetch_name(thing_type, sub_type):
	var dictionary_of_names = NAME_MAPPINGS.get(thing_type)
	if dictionary_of_names:
		var data_structure = data_structure(thing_type)
		var sub_type_data = data_structure.get(sub_type)
		if sub_type_data:
			var nameId = sub_type_data[NAME_ID]
			return dictionary_of_names.get(nameId, nameId.capitalize())
		else:
			return "Unknown " + data_structure_name[thing_type] + " Subtype: " + str(sub_type)
	else:
		return "Unknown Thingtype " + str(thing_type) + ", Subtype: " + str(sub_type)




const NAME_MAPPINGS = {
	TYPE.EXTRA : {
		"ACTIONPOINT" : "Action Point",
		"LIGHT" : "Light",
	},
	TYPE.DOOR : {
		"WOOD" : "Wooden Door",
		"BRACED" : "Braced Door",
		"STEEL" : "Iron Door",
		"MAGIC" : "Magic Door",
	},
	TYPE.TRAP : {
		"BOULDER" : "Boulder Trap",
		"ALARM" : "Alarm Trap",
		"POISON_GAS" : "Poison Gas Trap",
		"LIGHTNING" : "Lightning Trap",
		"WORD_OF_POWER" : "Word of Power Trap",
		"LAVA" : "Lava Trap",
		"TNT" : "Dummy Trap 2",
		"DUMMYTRAP3" : "Dummy Trap 3",
		"DUMMYTRAP4" : "Dummy Trap 4",
		"DUMMYTRAP5" : "Dummy Trap 5",
		"DUMMYTRAP6" : "Dummy Trap 6",
		"DUMMYTRAP7" : "Dummy Trap 7",
	},
	TYPE.EFFECTGEN : {
		"EFFECTGENERATOR_LAVA" : "Lava Effect",
		"EFFECTGENERATOR_DRIPPING_WATER" : "Dripping Water Effect",
		"EFFECTGENERATOR_ROCK_FALL" : "Rock Fall Effect",
		"EFFECTGENERATOR_ENTRANCE_ICE" : "Entrance Ice Effect",
		"EFFECTGENERATOR_DRY_ICE" : "Dry Ice Effect",
	},
	TYPE.CREATURE : {
		"WIZARD" : "Wizard",
		"BARBARIAN" : "Barbarian",
		"ARCHER" : "Archer",
		"MONK" : "Monk",
		"DWARFA" : "Dwarf",
		"KNIGHT" : "Knight",
		"AVATAR" : "Avatar",
		"TUNNELLER" : "Tunneller",
		"WITCH" : "Witch",
		"GIANT" : "Giant",
		"FAIRY" : "Fairy",
		"THIEF" : "Thief",
		"SAMURAI" : "Samurai",
		"HORNY" : "Horned Reaper",
		"SKELETON" : "Skeleton",
		"TROLL" : "Troll",
		"DRAGON" : "Dragon",
		"DEMONSPAWN" : "Demon Spawn",
		"FLY" : "Fly",
		"DARK_MISTRESS" : "Dark Mistress",
		"SORCEROR" : "Warlock",
		"BILE_DEMON" : "Bile Demon",
		"IMP" : "Imp",
		"BUG" : "Beetle",
		"VAMPIRE" : "Vampire",
		"SPIDER" : "Spider",
		"HELL_HOUND" : "Hell Hound",
		"GHOST" : "Ghost",
		"TENTACLE" : "Tentacle",
		"ORC" : "Orc",
		"FLOATING_SPIRIT" : "Floating Spirit",
		"TIME_MAGE" : "Time Mage",
		"DRUID" : "Druid",
	},
	TYPE.OBJECT : {
		"BARREL" : "Barrel",
		"TORCH" : "Torch",
		"GOLD_CHEST" : "Gold Pot (500)",
		"TEMPLE_STATUE" : "Lit Statue",
		"SOUL_CONTAINER" : "Dungeon Heart",
		"GOLD" : "Gold Pot (250)",
		"TORCHUN" : "Unlit Torch",
		"STATUEWO" : "Glowing Statue",
		"CHICKEN_GRW" : "Egg Growing (1)",
		"CHICKEN_MAT" : "Chicken",
		"SPELLBOOK_HOE" : "Hand Of Evil",
		"SPELLBOOK_IMP" : "Create Imp",
		"SPELLBOOK_OBEY" : "Must Obey",
		"SPELLBOOK_SLAP" : "Slap",
		"SPELLBOOK_SOE" : "Sight of Evil",
		"SPELLBOOK_CTA" : "Call To Arms",
		"SPELLBOOK_CAVI" : "Cave-In",
		"SPELLBOOK_HEAL" : "Heal",
		"SPELLBOOK_HLDAUD" : "Hold Audience",
		"SPELLBOOK_LIGHTN" : "Lightning Strike",
		"SPELLBOOK_SPDC" : "Speed Monster",
		"SPELLBOOK_PROT" : "Protect Monster",
		"SPELLBOOK_CONCL" : "Conceal Monster",
		"CTA_ENSIGN" : "Cta Ensign",
		"ROOM_FLAG" : "Room Flag",
		"ANVIL" : "Anvil",
		"PRISON_BAR" : "Prison Bar",
		"CANDLESTCK" : "Candlestick",
		"GRAVE_STONE" : "Gravestone",
		"STATUE_HORNY" : "Aztec Statue",
		"TRAINING_POST" : "Training Post",
		"TORTURE_SPIKE" : "Torture Spike",
		"TEMPLE_SPANGLE" : "Temple Spangle",
		"POTION_PURPLE" : "Purple Potion",
		"POTION_BLUE" : "Blue Potion",
		"POTION_GREEN" : "Green Potion",
		"POWER_HAND" : "Power Hand",
		"POWER_HAND_GRAB" : "Power Hand Grab",
		"POWER_HAND_WHIP" : "Power Hand Whip",
		"CHICKEN_STB" : "Egg Stable (2)",
		"CHICKEN_WOB" : "Egg Wobbling (3)",
		"CHICKEN_CRK" : "Egg Cracking (4)",
		"GOLDL" : "Gold Pile (200)",
		"SPINNING_KEY" : "Spinning Key",
		"SPELLBOOK_DISEASE" : "Disease",
		"SPELLBOOK_CHKN" : "Chicken Spell",
		"SPELLBOOK_DWAL" : "Destroy Walls",
		"SPELLBOOK_TBMB" : "Time Bomb",
		"HERO_GATE" : "Hero Gate",
		"SPINNING_KEY2" : "Spinning Key 2",
		"ARMOUR" : "Armour Effect",
		"GOLD_HOARD_1" : "Treasury Hoard 1 (400)",
		"GOLD_HOARD_2" : "Treasury Hoard 2 (800)",
		"GOLD_HOARD_3" : "Treasury Hoard 3 (1200)",
		"GOLD_HOARD_4" : "Treasury Hoard 4 (1600)",
		"GOLD_HOARD_5" : "Treasury Hoard 5 (2000)",
		"LAIR_WIZRD" : "Wizard Lair",
		"LAIR_BARBR" : "Barbarian Lair",
		"LAIR_ARCHR" : "Archer Lair",
		"LAIR_MONK" : "Monk Lair",
		"LAIR_DWRFA" : "Dwarf Lair",
		"LAIR_KNGHT" : "Knight Lair",
		"LAIR_AVATR" : "Avatar Lair",
		"LAIR_TUNLR" : "Tunneller Lair",
		"LAIR_WITCH" : "Witch Lair",
		"LAIR_GIANT" : "Giant Lair",
		"LAIR_FAIRY" : "Fairy Lair",
		"LAIR_THIEF" : "Thief Lair",
		"LAIR_SAMUR" : "Samurai Lair",
		"LAIR_HORNY" : "Horned Reaper Lair",
		"LAIR_SKELT" : "Skeleton Lair",
		"LAIR_GOBLN" : "Troll Lair",
		"LAIR_DRAGN" : "Dragon Lair",
		"LAIR_DEMSP" : "Demon Spawn Lair",
		"LAIR_FLY" : "Fly Lair",
		"LAIR_DKMIS" : "Mistress Lair",
		"LAIR_SORCR" : "Warlock Lair",
		"LAIR_BILDM" : "Bile Demon Lair",
		"LAIR_IMP" : "Imp Lair",
		"LAIR_BUG" : "Beetle Lair",
		"LAIR_VAMP" : "Vampire Lair",
		"LAIR_SPIDR" : "Spider Lair",
		"LAIR_HLHND" : "Hell Hound Lair",
		"LAIR_GHOST" : "Ghost Lair",
		"LAIR_TENTC" : "Tentacle Lair",
		"SPECBOX_REVMAP" : "Reveal Map",
		"SPECBOX_RESURCT" : "Resurrect Creature",
		"SPECBOX_TRANSFR" : "Transfer Creature",
		"SPECBOX_STEALHR" : "Steal Hero",
		"SPECBOX_MULTPLY" : "Multiply Creatures",
		"SPECBOX_INCLEV" : "Increase Level",
		"SPECBOX_MKSAFE" : "Make Safe",
		"SPECBOX_HIDNWRL" : "Locate Hidden World",
		"WRKBOX_BOULDER" : "Box: Boulder Trap",
		"WRKBOX_ALARM" : "Box: Alarm Trap",
		"WRKBOX_POISONG" : "Box: Poison Gas Trap",
		"WRKBOX_LIGHTNG" : "Box: Lightning Trap",
		"WRKBOX_WRDOFPW" : "Box: Word of Power Trap",
		"WRKBOX_LAVA" : "Box: Lava Trap",
		"WRKBOX_DEMOLTN" : "Box: Dummy Trap 2",
		"WRKBOX_DUMMY3" : "Box: Dummy Trap 3",
		"WRKBOX_DUMMY4" : "Box: Dummy Trap 4",
		"WRKBOX_DUMMY5" : "Box: Dummy Trap 5",
		"WRKBOX_DUMMY6" : "Box: Dummy Trap 6",
		"WRKBOX_DUMMY7" : "Box: Dummy Trap 7",
		"WRKBOX_WOOD" : "Box: Wooden Door",
		"WRKBOX_BRACE" : "Box: Braced Door",
		"WRKBOX_STEEL" : "Box: Iron Door",
		"WRKBOX_MAGIC" : "Box: Magic Door",
		"WRKBOX_ITEM" : "Workshop Item",
		"HEARTFLAME_RED" : "Red Heart Flame",
		"DISEASE" : "Disease Effect",
		"SCAVENGE_EYE" : "Scavenger Eye",
		"WORKSHOP_MACHINE" : "Workshop Machine",
		"GUARDFLAG_RED" : "Red Flag",
		"GUARDFLAG_BLUE" : "Blue Flag",
		"GUARDFLAG_GREEN" : "Green Flag",
		"GUARDFLAG_YELLOW" : "Yellow Flag",
		"FLAG_POST" : "Flagpole",
		"HEARTFLAME_BLUE" : "Blue Heart Flame",
		"HEARTFLAME_GREEN" : "Green Heart Flame",
		"HEARTFLAME_YELLOW" : "Yellow Heart Flame",
		"POWER_SIGHT" : "Casted Sight",
		"POWER_LIGHTNG" : "Casted Lightning",
		"TORTURER" : "Torturer",
		"LAIR_ORC" : "Orc Lair",
		"POWER_HAND_GOLD" : "Power Hand Gold",
		"SPINNCOIN" : "Spinning Coin",
		"STATUE2" : "Unlit Statue",
		"STATUE3" : "Statue 3",
		"STATUE4" : "Statue 4",
		"STATUE5" : "Statue 5",
		"SPECBOX_CUSTOM" : "Mysterious Box",
		"SPELLBOOK_ARMG" : "Armageddon Spell",
		"SPELLBOOK_POSS" : "Possess Spell",
		"GOLD_BAG" : "Gold Bag",
		"FERN" : "Fern",
		"FERN_BROWN" : "Brown Fern",
		"FERN_SMALL" : "Small Fern",
		"FERN_SMALL_BROWN" : "Small Brown Fern",
		"MUSHROOM_YELLOW" : "Yellow Mushroom",
		"MUSHROOM_GREEN" : "Green Mushroom",
		"MUSHROOM_RED" : "Red Mushroom",
		"LAIR_TMAGE" : "Time Mage Lair",
		"LAIR_DRUID" : "Druid Lair",
		"LILYPAD" : "Lilypad",
		"CATTAILS" : "Cattails",
		"BANNER" : "Banner",
		"LANTERN_PST" : "Lantern Post",
		"POTION_RED" : "Red Potion",
		"POTION_BROWN" : "Brown Potion",
		"POTION_WHITE" : "White Potion",
		"POTION_YELLOW" : "Yellow Potion",
		"ROCK_PILLAR" : "Rock Pillar",
		"ROCK" : "Rock",
		"LAVA_PILLAR" : "Lava Pillar",
		"LAVA_ROCK" : "Lava Rock",
		"ICE_PILLAR" : "Ice Pillar",
		"ICE_ROCK" : "Ice Rock",
		"WRKBOX_SECRET" : "Box: Secret Door",
		"GUARDFLAG_WHITE" : "White Flag",
		"HEARTFLAME_WHITE" : "White Heart Flame",
		"SPELLBOOK_RBND" : "Rebound",
		"GUARDFLAG_PURPLE" : "Purple Flag",
		"HEARTFLAME_PURPLE" : "Purple Heart Flame",
		"GUARDFLAG_BLACK" : "Black Flag",
		"HEARTFLAME_BLACK" : "Black Heart Flame",
		"GUARDFLAG_ORANGE" : "Orange Flag",
		"HEARTFLAME_ORANGE" : "Orange Heart Flame",
		"SPECBOX_HEALALL" : "Heal All",
		"SPECBOX_GETGOLD" : "Increase Gold",
		"SPECBOX_MKANGRY" : "Make Unhappy",
		"SPECBOX_MKUNSAFE" : "Weaken Walls",
		"SPELLBOOK_FRZ" : "Freeze",
		"SPELLBOOK_SLOW" : "Slow",
		"SPELLBOOK_FLGT" : "Flight",
		"SPELLBOOK_VSN" : "Vision"
	}
}

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

enum { # I only used the official DK keeperfx categories as a guide rather than strict adherence. What strict adherence gets you is all the egg objects classified as Furniture, while Chicken sits alone in its own Food category.
	TAB_ACTION
	TAB_CREATURE
	TAB_GOLD
	TAB_TRAP
	TAB_SPELL
	TAB_SPECIAL
	TAB_BOX
	TAB_LAIR
	TAB_EFFECTGEN
	TAB_FURNITURE
	TAB_DECORATION
	TAB_MISC
}

var GENRE_TO_TAB = {
	"DECORATION": TAB_DECORATION,
	"EFFECT": TAB_EFFECTGEN,
	"FOOD": TAB_FURNITURE,
	"FURNITURE": TAB_FURNITURE,
	"LAIR_TOTEM": TAB_LAIR,
	"POWER": TAB_MISC,
	"SPECIALBOX": TAB_SPECIAL,
	"SPELLBOOK": TAB_SPELL,
	"TREASURE_HOARD": TAB_GOLD,
	"VALUABLE": TAB_GOLD,
	"WORKSHOPBOX": TAB_BOX,
}

var DATA_EXTRA = {
0 : [null, null, null, null],
1 : ["ACTIONPOINT", "IMG_ACTIONPOINT", null, TAB_ACTION],
2 : ["LIGHT", "IMG_LIGHT", null, TAB_EFFECTGEN],
}

var DATA_DOOR = { #
0 : [null, null, null, null],
1 : ["WOOD", "IMG_WOOD" , null, TAB_MISC],
2 : ["BRACED", "IMG_BRACED", null, TAB_MISC],
3 : ["STEEL", "IMG_STEEL", null, TAB_MISC],
4 : ["MAGIC", "IMG_MAGIC", null, TAB_MISC]
}

var DATA_TRAP = {
00 : [null, null, null, null],
01 : ["BOULDER", "IMG_BOULDER", null, TAB_TRAP],
02 : ["ALARM", "IMG_ALARM", null, TAB_TRAP],
03 : ["POISON_GAS", "IMG_POISON_GAS", null, TAB_TRAP],
04 : ["LIGHTNING", "IMG_LIGHTNING_TRAP", null, TAB_TRAP],
05 : ["WORD_OF_POWER", "IMG_WORD_OF_POWER", null, TAB_TRAP],
06 : ["LAVA", "IMG_LAVA", null, TAB_TRAP],
07 : ["TNT", "IMG_TNT", null, TAB_TRAP],
08 : ["DUMMYTRAP3", null, null, null, TAB_TRAP],
09 : ["DUMMYTRAP4", null, null, null, TAB_TRAP],
10 : ["DUMMYTRAP5", null, null, null, TAB_TRAP],
11 : ["DUMMYTRAP6", null, null, null, TAB_TRAP],
12 : ["DUMMYTRAP7", null, null, null, TAB_TRAP],
}

var DATA_EFFECTGEN = {
0 : [null, null, null, null],
1 : ["EFFECTGENERATOR_LAVA", "IMG_EFFECTGENERATOR_LAVA", null, TAB_EFFECTGEN],
2 : ["EFFECTGENERATOR_DRIPPING_WATER", "IMG_EFFECTGENERATOR_DRIPPING_WATER", null, TAB_EFFECTGEN],
3 : ["EFFECTGENERATOR_ROCK_FALL", "IMG_EFFECTGENERATOR_ROCK_FALL", null, TAB_EFFECTGEN],
4 : ["EFFECTGENERATOR_ENTRANCE_ICE", "IMG_EFFECTGENERATOR_ENTRANCE_ICE", null, TAB_EFFECTGEN],
5 : ["EFFECTGENERATOR_DRY_ICE", "IMG_EFFECTGENERATOR_DRY_ICE", null, TAB_EFFECTGEN]
}

var DATA_CREATURE = {
00 : [null, null, null, null],
01 : ["WIZARD",          "IMG_WIZARD", "IMG_WIZARD_PORTRAIT", TAB_CREATURE],
02 : ["BARBARIAN",       "IMG_BARBARIAN", "IMG_BARBARIAN_PORTRAIT", TAB_CREATURE],
03 : ["ARCHER",          "IMG_ARCHER", "IMG_ARCHER_PORTRAIT", TAB_CREATURE],
04 : ["MONK",            "IMG_MONK",  "IMG_MONK_PORTRAIT", TAB_CREATURE],
05 : ["DWARFA",          "IMG_DWARFA", "IMG_DWARFA_PORTRAIT", TAB_CREATURE],
06 : ["KNIGHT",          "IMG_KNIGHT", "IMG_KNIGHT_PORTRAIT", TAB_CREATURE],
07 : ["AVATAR",          "IMG_AVATAR", "IMG_AVATAR_PORTRAIT", TAB_CREATURE],
08 : ["TUNNELLER",       "IMG_TUNNELLER", "IMG_TUNNELLER_PORTRAIT", TAB_CREATURE],
09 : ["WITCH",           "IMG_WITCH", "IMG_WITCH_PORTRAIT", TAB_CREATURE],
10 : ["GIANT",           "IMG_GIANT", "IMG_GIANT_PORTRAIT", TAB_CREATURE],
11 : ["FAIRY",           "IMG_FAIRY", "IMG_FAIRY_PORTRAIT", TAB_CREATURE],
12 : ["THIEF",           "IMG_THIEF", "IMG_THIEF_PORTRAIT", TAB_CREATURE],
13 : ["SAMURAI",         "IMG_SAMURAI", "IMG_SAMURAI_PORTRAIT", TAB_CREATURE],
14 : ["HORNY",           "IMG_HORNY", "IMG_HORNY_PORTRAIT", TAB_CREATURE],
15 : ["SKELETON",        "IMG_SKELETON", "IMG_SKELETON_PORTRAIT", TAB_CREATURE],
16 : ["TROLL",           "IMG_TROLL", "IMG_TROLL_PORTRAIT", TAB_CREATURE],
17 : ["DRAGON",          "IMG_DRAGON", "IMG_DRAGON_PORTRAIT", TAB_CREATURE],
18 : ["DEMONSPAWN",      "IMG_DEMONSPAWN", "IMG_DEMONSPAWN_PORTRAIT", TAB_CREATURE],
19 : ["FLY",             "IMG_FLY",   "IMG_FLY_PORTRAIT", TAB_CREATURE],
20 : ["DARK_MISTRESS",   "IMG_DARK_MISTRESS", "IMG_DARK_MISTRESS_PORTRAIT", TAB_CREATURE],
21 : ["SORCEROR",        "IMG_SORCEROR", "IMG_SORCEROR_PORTRAIT", TAB_CREATURE],
22 : ["BILE_DEMON",      "IMG_BILE_DEMON", "IMG_BILE_DEMON_PORTRAIT", TAB_CREATURE],
23 : ["IMP",             "IMG_IMP",   "IMG_IMP_PORTRAIT", TAB_CREATURE],
24 : ["BUG",             "IMG_BUG",   "IMG_BUG_PORTRAIT", TAB_CREATURE],
25 : ["VAMPIRE",         "IMG_VAMPIRE", "IMG_VAMPIRE_PORTRAIT", TAB_CREATURE],
26 : ["SPIDER",          "IMG_SPIDER", "IMG_SPIDER_PORTRAIT", TAB_CREATURE],
27 : ["HELL_HOUND",      "IMG_HELL_HOUND", "IMG_HELL_HOUND_PORTRAIT", TAB_CREATURE],
28 : ["GHOST",           "IMG_GHOST", "IMG_GHOST_PORTRAIT", TAB_CREATURE],
29 : ["TENTACLE",        "IMG_TENTACLE", "IMG_TENTACLE_PORTRAIT", TAB_CREATURE],
30 : ["ORC",             "IMG_ORC",   "IMG_ORC_PORTRAIT", TAB_CREATURE],
31 : ["FLOATING_SPIRIT", "IMG_FLOATING_SPIRIT", "IMG_FLOATING_SPIRIT_PORTRAIT", TAB_CREATURE], # wrong icon probably
}

var DATA_OBJECT = {
000 : [null, null, null, null],
001 : ["BARREL", 930, null, TAB_DECORATION],
002 : ["TORCH", 962, null, TAB_DECORATION], #TAB_FURNITURE
003 : ["GOLD_CHEST", 934, null, TAB_GOLD],
004 : ["TEMPLE_STATUE", 950, null, TAB_DECORATION], #TAB_FURNITURE
005 : ["SOUL_CONTAINER", 948, null, TAB_FURNITURE],
006 : ["GOLD", 934, null, TAB_GOLD],
007 : ["TORCHUN", 962, null, TAB_DECORATION], #TAB_FURNITURE
008 : ["STATUEWO", 950, null, TAB_DECORATION], #Lit Statue No Flame # Partially Lit Statue
009 : ["CHICKEN_GRW", 893, null, TAB_MISC],
010 : ["CHICKEN_MAT", 819, null, TAB_MISC],
011 : ["SPELLBOOK_HOE", "IMG_HAND_OF_EVIL", null, TAB_SPELL],
012 : ["SPELLBOOK_IMP", "IMG_IMP", null, TAB_SPELL],
013 : ["SPELLBOOK_OBEY", "IMG_MUST_OBEY", null, TAB_SPELL],
014 : ["SPELLBOOK_SLAP", "IMG_SLAP", null, TAB_SPELL],
015 : ["SPELLBOOK_SOE", "IMG_SIGHT_OF_EVIL", null, TAB_SPELL],
016 : ["SPELLBOOK_CTA", "IMG_CALL_TO_ARMS", null, TAB_SPELL],
017 : ["SPELLBOOK_CAVI", "IMG_CAVE_IN", null, TAB_SPELL],
018 : ["SPELLBOOK_HEAL", "IMG_HEAL_CREATURE", null, TAB_SPELL],
019 : ["SPELLBOOK_HLDAUD", "IMG_HOLD_AUDIENCE", null, TAB_SPELL],
020 : ["SPELLBOOK_LIGHTN", "IMG_LIGHTNING", null, TAB_SPELL],
021 : ["SPELLBOOK_SPDC", "IMG_SPEED_CREATURE", null, TAB_SPELL],
022 : ["SPELLBOOK_PROT", "IMG_PROTECT_CREATURE", null, TAB_SPELL],
023 : ["SPELLBOOK_CONCL", "IMG_CONCEAL_CREATURE", null, TAB_SPELL],
024 : ["CTA_ENSIGN", null, null, TAB_MISC],
025 : ["ROOM_FLAG", null, null, TAB_MISC],
026 : ["ANVIL", 789, null, TAB_FURNITURE],
027 : ["PRISON_BAR", 796, null, TAB_FURNITURE],
028 : ["CANDLESTCK", 791, null, TAB_DECORATION], #TAB_FURNITURE
029 : ["GRAVE_STONE", 793, null, TAB_FURNITURE],
030 : ["STATUE_HORNY", 905, null, TAB_DECORATION], #TAB_FURNITURE
031 : ["TRAINING_POST", 795, null, TAB_FURNITURE],
032 : ["TORTURE_SPIKE", 892, null, TAB_FURNITURE],
033 : ["TEMPLE_SPANGLE", 797, null, TAB_DECORATION],
034 : ["POTION_PURPLE", 804, null, TAB_DECORATION],
035 : ["POTION_BLUE", 806, null, TAB_DECORATION],
036 : ["POTION_GREEN", 808, null, TAB_DECORATION],
037 : ["POWER_HAND", 782, null, TAB_MISC],
038 : ["POWER_HAND_GRAB", 783, null, TAB_MISC],
039 : ["POWER_HAND_WHIP", 785, null, TAB_MISC],
040 : ["CHICKEN_STB", 894, null, TAB_MISC],
041 : ["CHICKEN_WOB", 895, null, TAB_MISC],
042 : ["CHICKEN_CRK", 896, null, TAB_MISC],
043 : ["GOLDL", 936, null, TAB_GOLD],
044 : ["SPINNING_KEY", 810, null, TAB_MISC],
045 : ["SPELLBOOK_DISEASE", "IMG_DISEASE", null, TAB_SPELL],
046 : ["SPELLBOOK_CHKN", "IMG_CHICKEN", null, TAB_SPELL],
047 : ["SPELLBOOK_DWAL", "IMG_DESTROY_WALLS", null, TAB_SPELL],
048 : ["SPELLBOOK_TBMB", "IMG_TIME_BOMB", null, TAB_SPELL],
049 : ["HERO_GATE", 776, null, TAB_ACTION],
050 : ["SPINNING_KEY2", 810, null, TAB_MISC],
051 : ["ARMOUR", null, null, TAB_MISC],
052 : ["GOLD_HOARD_1", 936, null, TAB_GOLD],
053 : ["GOLD_HOARD_2", 937, null, TAB_GOLD],
054 : ["GOLD_HOARD_3", 938, null, TAB_GOLD],
055 : ["GOLD_HOARD_4", 939, null, TAB_GOLD],
056 : ["GOLD_HOARD_5", 940, null, TAB_GOLD],
057 : ["LAIR_WIZRD", 124, null, TAB_LAIR],
058 : ["LAIR_BARBR", 124, null, TAB_LAIR],
059 : ["LAIR_ARCHR", 124, null, TAB_LAIR],
060 : ["LAIR_MONK", 124, null, TAB_LAIR],
061 : ["LAIR_DWRFA", 124, null, TAB_LAIR],
062 : ["LAIR_KNGHT", 124, null, TAB_LAIR],
063 : ["LAIR_AVATR", 124, null, TAB_LAIR],
064 : ["LAIR_TUNLR", 124, null, TAB_LAIR],
065 : ["LAIR_WITCH", 124, null, TAB_LAIR],
066 : ["LAIR_GIANT", 124, null, TAB_LAIR],
067 : ["LAIR_FAIRY", 124, null, TAB_LAIR],
068 : ["LAIR_THIEF", 124, null, TAB_LAIR],
069 : ["LAIR_SAMUR", 124, null, TAB_LAIR],
070 : ["LAIR_HORNY", 158, null, TAB_LAIR],
071 : ["LAIR_SKELT", 156, null, TAB_LAIR],
072 : ["LAIR_GOBLN", 154, null, TAB_LAIR],
073 : ["LAIR_DRAGN", 152, null, TAB_LAIR],
074 : ["LAIR_DEMSP", 150, null, TAB_LAIR],
075 : ["LAIR_FLY", 148, null, TAB_LAIR],
076 : ["LAIR_DKMIS", 146, null, TAB_LAIR],
077 : ["LAIR_SORCR", 144, null, TAB_LAIR],
078 : ["LAIR_BILDM", 142, null, TAB_LAIR],
079 : ["LAIR_IMP", 152, null, TAB_LAIR],
080 : ["LAIR_BUG", 140, null, TAB_LAIR],
081 : ["LAIR_VAMP", 138, null, TAB_LAIR],
082 : ["LAIR_SPIDR", 136, null, TAB_LAIR],
083 : ["LAIR_HLHND", 134, null, TAB_LAIR],
084 : ["LAIR_GHOST", 132, null, TAB_LAIR],
085 : ["LAIR_TENTC", 128, null, TAB_LAIR],
086 : ["SPECBOX_REVMAP", 901, null, TAB_SPECIAL],
087 : ["SPECBOX_RESURCT", 901, null, TAB_SPECIAL],
088 : ["SPECBOX_TRANSFR", 901, null, TAB_SPECIAL],
089 : ["SPECBOX_STEALHR", 901, null, TAB_SPECIAL],
090 : ["SPECBOX_MULTPLY", 901, null, TAB_SPECIAL],
091 : ["SPECBOX_INCLEV", 901, null, TAB_SPECIAL],
092 : ["SPECBOX_MKSAFE", 901, null, TAB_SPECIAL],
093 : ["SPECBOX_HIDNWRL", 901, null, TAB_SPECIAL],
094 : ["WRKBOX_BOULDER", 114, null, TAB_BOX],
095 : ["WRKBOX_ALARM", 114, null, TAB_BOX],
096 : ["WRKBOX_POISONG", 114, null, TAB_BOX],
097 : ["WRKBOX_LIGHTNG", 114, null, TAB_BOX],
098 : ["WRKBOX_WRDOFPW", 114, null, TAB_BOX],
099 : ["WRKBOX_LAVA", 114, null, TAB_BOX],
100 : ["WRKBOX_DEMOLTN", 114, null, TAB_BOX],
101 : ["WRKBOX_DUMMY3", 114, null, TAB_BOX],
102 : ["WRKBOX_DUMMY4", 114, null, TAB_BOX],
103 : ["WRKBOX_DUMMY5", 114, null, TAB_BOX],
104 : ["WRKBOX_DUMMY6", 114, null, TAB_BOX],
105 : ["WRKBOX_DUMMY7", 114, null, TAB_BOX],
106 : ["WRKBOX_WOOD", 114, null, TAB_BOX],
107 : ["WRKBOX_BRACE", 114, null, TAB_BOX],
108 : ["WRKBOX_STEEL", 114, null, TAB_BOX],
109 : ["WRKBOX_MAGIC", 114, null, TAB_BOX],
110 : ["WRKBOX_ITEM", 789, null, TAB_MISC],
111 : ["HEARTFLAME_RED", 798, null, TAB_FURNITURE],
112 : ["DISEASE", null, null, TAB_MISC],
113 : ["SCAVENGE_EYE", 130, null, TAB_FURNITURE],
114 : ["WORKSHOP_MACHINE", 98, null, TAB_FURNITURE],
115 : ["GUARDFLAG_RED", 102, null, TAB_FURNITURE],
116 : ["GUARDFLAG_BLUE", 104, null, TAB_FURNITURE],
117 : ["GUARDFLAG_GREEN", 106, null, TAB_FURNITURE],
118 : ["GUARDFLAG_YELLOW", 108, null, TAB_FURNITURE],
119 : ["FLAG_POST", 100, null, TAB_FURNITURE],
120 : ["HEARTFLAME_BLUE", 799, null, TAB_FURNITURE],
121 : ["HEARTFLAME_GREEN", 800, null, TAB_FURNITURE],
122 : ["HEARTFLAME_YELLOW", 801, null, TAB_FURNITURE],
123 : ["POWER_SIGHT", "IMG_POWER_SIGHT", null, TAB_MISC],
124 : ["POWER_LIGHTNG", null, null, TAB_MISC],
125 : ["TORTURER", 46, null, TAB_FURNITURE],
126 : ["LAIR_ORC", 126, null, TAB_LAIR],
127 : ["POWER_HAND_GOLD", 781, null, TAB_MISC],
128 : ["SPINNCOIN", null, null, TAB_MISC],
129 : ["STATUE2", 952, null, TAB_DECORATION],
130 : ["STATUE3", "GOLDEN_ARMOR", null, TAB_DECORATION],
131 : ["STATUE4", "KNIGHTSTATUE", null, TAB_DECORATION],
132 : ["STATUE5", 958, null, TAB_DECORATION],
133 : ["SPECBOX_CUSTOM", 901, null, TAB_SPECIAL],
134 : ["SPELLBOOK_ARMG", "IMG_ARMAGEDDON", null, TAB_SPELL],
135 : ["SPELLBOOK_POSS", "IMG_POSSESS_CREATURE", null, TAB_SPELL],
}

#136 : ["Gold Bag (100)", null, preload("res://dk_images/valuables/gold_sack_tp/r1frame01.png"), null, TAB_GOLD],
#161 : ["White Flag", null, preload("res://dk_images/furniture/flagpole_whiteflag_tp/AnimFlagpoleWhite.tres"), null, TAB_FURNITURE],
#162 : ["White Heart Flame", null, preload("res://edited_images/heartflames/heartflame_white/AnimWhiteHeartFlame.tres"), null, TAB_FURNITURE],
#164 : ["Purple Flag", null, preload("res://dk_images/furniture/flagpole_purpleflag_tp/AnimFlagpolePurple.tres"), null, TAB_FURNITURE],
#165 : ["Purple Heart Flame", null, preload("res://edited_images/heartflames/heartflame_purple/AnimPurpleHeartFlame.tres"), null, TAB_FURNITURE],
#166 : ["Black Flag", null, preload("res://dk_images/furniture/flagpole_blackflag_tp/AnimFlagpoleBlack.tres"), null, TAB_FURNITURE],
#167 : ["Black Heart Flame", null, preload("res://edited_images/heartflames/heartflame_black/AnimBlackHeartFlame.tres"), null, TAB_FURNITURE],
#168 : ["Orange Flag", null, preload("res://dk_images/furniture/flagpole_orangeflag_tp/AnimFlagpoleOrange.tres"), null, TAB_FURNITURE],
#169 : ["Orange Heart Flame", null, preload("res://edited_images/heartflames/heartflame_orange/AnimOrangeHeartFlame.tres"), null, TAB_FURNITURE],

func data_structure(thingType):
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
094 : [TYPE.TRAP, 1], # Boulder Trap
095 : [TYPE.TRAP, 2], # Alarm Trap
096 : [TYPE.TRAP, 3], # Poison Gas Trap
097 : [TYPE.TRAP, 4], # Lightning Trap
098 : [TYPE.TRAP, 5], # Word of Power Trap
099 : [TYPE.TRAP, 6], # Lava Trap
100 : [TYPE.TRAP, 7], # Demolition Trap
101 : [TYPE.TRAP, 8], # Dummy Trap 3
102 : [TYPE.TRAP, 9], # Dummy Trap 4
103 : [TYPE.TRAP, 10], # Dummy Trap 5
104 : [TYPE.TRAP, 11], # Dummy Trap 6
105 : [TYPE.TRAP, 12], # Dummy Trap 7
106 : [TYPE.DOOR, 1], # Wooden Door
107 : [TYPE.DOOR, 2], # Braced Door
108 : [TYPE.DOOR, 3], # Iron Door
109 : [TYPE.DOOR, 4], # Magic Door
}
var LIST_OF_GOLDPILES = [
	3, 6, 43, 128, 136
]

var LIST_OF_SPELLBOOKS = [
SPELLBOOK.HAND,
SPELLBOOK.SLAP,
SPELLBOOK.POSSESS,
SPELLBOOK.IMP,
SPELLBOOK.SIGHT,
SPELLBOOK.SPEED,
SPELLBOOK.OBEY,
SPELLBOOK.CALL_TO_ARMS,
SPELLBOOK.CONCEAL,
SPELLBOOK.HOLD_AUDIENCE,
SPELLBOOK.CAVE_IN,
SPELLBOOK.HEAL_CREATURE,
SPELLBOOK.LIGHTNING,
SPELLBOOK.PROTECT,
SPELLBOOK.CHICKEN,
SPELLBOOK.DISEASE,
SPELLBOOK.ARMAGEDDON,
SPELLBOOK.DESTROY_WALLS,
]

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
	TAB_GOLD : Slabs.TREASURE_ROOM,
	TAB_SPELL : Slabs.LIBRARY,
	TAB_SPECIAL : Slabs.LIBRARY,
	TAB_BOX : Slabs.WORKSHOP,
}

	#OBJECT = 1
	#CREATURE = 5
	#EFFECT = 7
	#TRAP = 8
	#DOOR = 9

func convert_relative_256_to_float(datnum):
	if datnum >= 32768: # If the sign bit is set (indicating a negative value)
		datnum -= 65536 # Convert to signed by subtracting 2^16
	return datnum / 256.0 # Scale it to floating-point
