extends Node2D

const THING_LIMIT = -1#2048
const ACTION_POINT_LIMIT = -1#255
const CREATURE_LIMIT = -1#255
const LIGHT_LIMIT = -1

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




enum {
	NAME_ID = 0
	ANIMATION_ID = 1
	TEXTURE = 2
	PORTRAIT = 3 # Keep PORTAIT field "null" if I want to use texture for portrait.
	EDITOR_TAB = 4
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
0 : [null, null, null, null, null],
1 : ["ACTIONPOINT", null,  preload("res://Art/ActionPoint.png"), null, TAB_ACTION],
2 : ["LIGHT", null, preload("res://edited_images/GUIEDIT-1/PIC26.png"), null, TAB_EFFECTGEN],
}

var DATA_DOOR = { #
0 : [null, null, null, null, null],
1 : ["WOOD", null, preload("res://dk_images/trapdoor_64/door_pers_wood_std.png"), null, TAB_MISC],
2 : ["BRACED", null, preload("res://dk_images/trapdoor_64/door_pers_braced_std.png"), null, TAB_MISC],
3 : ["STEEL", null, preload("res://dk_images/trapdoor_64/door_pers_iron_std.png"), null, TAB_MISC],
4 : ["MAGIC", null, preload("res://dk_images/trapdoor_64/door_pers_magic_std.png"), null, TAB_MISC]
}

var DATA_TRAP = {
00 : [null, null, null, null, null],
01 : ["BOULDER", null, preload("res://dk_images/trapdoor_64/trap_boulder_std.png"), null, TAB_TRAP],
02 : ["ALARM", null, preload("res://dk_images/trapdoor_64/trap_alarm_std.png"), null, TAB_TRAP],
03 : ["POISON_GAS", null, preload("res://dk_images/trapdoor_64/trap_gas_std.png"), null, TAB_TRAP],
04 : ["LIGHTNING", null, preload("res://dk_images/trapdoor_64/trap_lightning_std.png"), null, TAB_TRAP],
05 : ["WORD_OF_POWER", null, preload("res://dk_images/trapdoor_64/trap_wop_std.png"), null, TAB_TRAP],
06 : ["LAVA", null, preload("res://dk_images/trapdoor_64/trap_lava_std.png"), null, TAB_TRAP],
07 : ["TNT", null, null, null, TAB_TRAP],
08 : ["DUMMYTRAP3", null, null, null, null, TAB_TRAP],
09 : ["DUMMYTRAP4", null, null, null, null, TAB_TRAP],
10 : ["DUMMYTRAP5", null, null, null, null, TAB_TRAP],
11 : ["DUMMYTRAP6", null, null, null, null, TAB_TRAP],
12 : ["DUMMYTRAP7", null, null, null, null, TAB_TRAP],
}

var DATA_EFFECTGEN = {
0 : [null, null, null, null, null],
1 : ["EFFECTGENERATOR_LAVA", null, preload("res://edited_images/GUIEDIT-1/PIC27.png"), null, TAB_EFFECTGEN],
2 : ["EFFECTGENERATOR_DRIPPING_WATER", null, preload("res://edited_images/GUIEDIT-1/PIC28.png"), null, TAB_EFFECTGEN],
3 : ["EFFECTGENERATOR_ROCK_FALL", null, preload("res://edited_images/GUIEDIT-1/PIC29.png"), null, TAB_EFFECTGEN],
4 : ["EFFECTGENERATOR_ENTRANCE_ICE", null, preload("res://edited_images/GUIEDIT-1/PIC30.png"), null, TAB_EFFECTGEN],
5 : ["EFFECTGENERATOR_DRY_ICE", null, preload("res://edited_images/GUIEDIT-1/PIC31.png"), null, TAB_EFFECTGEN]
}

var DATA_CREATURE = {
00 : [null, null, null, null, null],
01 : ["WIZARD", null,          preload("res://edited_images/creatr_icon_64/wizrd_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_wizrd.png"), TAB_CREATURE],
02 : ["BARBARIAN", null,       preload("res://edited_images/creatr_icon_64/barbr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_barbr.png"), TAB_CREATURE],
03 : ["ARCHER", null,          preload("res://edited_images/creatr_icon_64/archr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_archr.png"), TAB_CREATURE],
04 : ["MONK", null,            preload("res://edited_images/creatr_icon_64/monk_std.png"),  preload("res://dk_images/creature_portrait_64/creatr_portrt_monk.png"), TAB_CREATURE],
05 : ["DWARFA", null,          preload("res://edited_images/creatr_icon_64/dwarf_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_dwrf1.png"), TAB_CREATURE],
06 : ["KNIGHT", null,          preload("res://edited_images/creatr_icon_64/knght_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_knigh.png"), TAB_CREATURE],
07 : ["AVATAR", null,          preload("res://edited_images/creatr_icon_64/avatr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_avatr.png"), TAB_CREATURE],
08 : ["TUNNELLER", null,       preload("res://edited_images/creatr_icon_64/tunlr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_dwrf2.png"), TAB_CREATURE],
09 : ["WITCH", null,           preload("res://edited_images/creatr_icon_64/prsts_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_witch.png"), TAB_CREATURE],
10 : ["GIANT", null,           preload("res://edited_images/creatr_icon_64/giant_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_giant.png"), TAB_CREATURE],
11 : ["FAIRY", null,           preload("res://edited_images/creatr_icon_64/fairy_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_fairy.png"), TAB_CREATURE],
12 : ["THIEF", null,           preload("res://edited_images/creatr_icon_64/thief_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_thief.png"), TAB_CREATURE],
13 : ["SAMURAI", null,         preload("res://edited_images/creatr_icon_64/samur_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_samur.png"), TAB_CREATURE],
14 : ["HORNY", null,           preload("res://edited_images/creatr_icon_64/hornd_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_horny.png"), TAB_CREATURE],
15 : ["SKELETON", null,        preload("res://edited_images/creatr_icon_64/skelt_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_skelt.png"), TAB_CREATURE],
16 : ["TROLL", null,           preload("res://edited_images/creatr_icon_64/troll_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_troll.png"), TAB_CREATURE],
17 : ["DRAGON", null,          preload("res://edited_images/creatr_icon_64/dragn_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_dragn.png"), TAB_CREATURE],
18 : ["DEMONSPAWN", null,      preload("res://edited_images/creatr_icon_64/dspwn_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_spawn.png"), TAB_CREATURE],
19 : ["FLY", null,             preload("res://edited_images/creatr_icon_64/fly_std.png"),   preload("res://dk_images/creature_portrait_64/creatr_portrt_fly.png"), TAB_CREATURE],
20 : ["DARK_MISTRESS", null,   preload("res://edited_images/creatr_icon_64/dkmis_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_mistr.png"), TAB_CREATURE],
21 : ["SORCEROR", null,        preload("res://edited_images/creatr_icon_64/warlk_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_warlk.png"), TAB_CREATURE],
22 : ["BILE_DEMON", null,      preload("res://edited_images/creatr_icon_64/biled_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_biled.png"), TAB_CREATURE],
23 : ["IMP", null,             preload("res://edited_images/creatr_icon_64/imp_std.png"),   preload("res://dk_images/creature_portrait_64/creatr_portrt_imp.png"), TAB_CREATURE],
24 : ["BUG", null,             preload("res://edited_images/creatr_icon_64/bug_std.png"),   preload("res://dk_images/creature_portrait_64/creatr_portrt_bug.png"), TAB_CREATURE],
25 : ["VAMPIRE", null,         preload("res://edited_images/creatr_icon_64/vampr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_vampr.png"), TAB_CREATURE],
26 : ["SPIDER", null,          preload("res://edited_images/creatr_icon_64/spidr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_spidr.png"), TAB_CREATURE],
27 : ["HELL_HOUND", null,      preload("res://edited_images/creatr_icon_64/hound_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_hound.png"), TAB_CREATURE],
28 : ["GHOST", null,           preload("res://edited_images/creatr_icon_64/ghost_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_ghost.png"), TAB_CREATURE],
29 : ["TENTACLE", null,        preload("res://edited_images/creatr_icon_64/tentc_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_tentc.png"), TAB_CREATURE],
30 : ["ORC", null,             preload("res://edited_images/creatr_icon_64/orc_std.png"),   preload("res://dk_images/creature_portrait_64/creatr_portrt_orc.png"), TAB_CREATURE],
31 : ["FLOATING_SPIRIT", null, preload("res://dk_images/magic_dust/anim0981/r1frame02.png"), preload("res://dk_images/magic_dust/anim0981/r1frame02.png"), TAB_CREATURE], # wrong icon probably
}

var DATA_OBJECT = {
000 : [null, null, null, null, null],
001 : ["BARREL", null, preload("res://dk_images/other/anim0932/r1frame01.png"), null, TAB_DECORATION],
002 : ["TORCH", null, preload("res://dk_images/other/anim0963/r1frame01.png"), null, TAB_DECORATION], #TAB_FURNITURE
003 : ["GOLD_CHEST", null, preload("res://dk_images/valuables/gold_pot_tp/AnimGoldPot.tres"), null, TAB_GOLD],
004 : ["TEMPLE_STATUE", null, preload("res://dk_images/statues/anim0952/AnimLitStatue.tres"), null, TAB_DECORATION], #TAB_FURNITURE
005 : ["SOUL_CONTAINER", null, preload("res://dk_images/crucials/anim0950/AnimDungeonHeart.tres"), null, TAB_FURNITURE],
006 : ["GOLD", null, preload("res://dk_images/valuables/gold_pot_tp/AnimGoldPot.tres"), null, TAB_GOLD],
007 : ["TORCHUN", null, preload("res://dk_images/other/anim0963/r1frame01.png"), null, TAB_DECORATION], #TAB_FURNITURE
008 : ["STATUEWO", null, preload("res://dk_images/statues/anim0952/AnimLitStatue.tres"), null, TAB_DECORATION], #Lit Statue No Flame # Partially Lit Statue
009 : ["CHICKEN_GRW", null, preload("res://dk_images/food/anim0898/AnimEggGrowing1.tres"), null, TAB_MISC],
010 : ["CHICKEN_MAT", null, preload("res://dk_images/food/anim0822/AnimChicken.tres"), null, TAB_MISC],
011 : ["SPELLBOOK_HOE", null, preload("res://edited_images/icon_handofevil.png"), null, TAB_SPELL],
012 : ["SPELLBOOK_IMP", null, preload("res://dk_images/keepower_64/imp_std.png"), null, TAB_SPELL],
013 : ["SPELLBOOK_OBEY", null, preload("res://edited_images/mustobey.png"), null, TAB_SPELL],
014 : ["SPELLBOOK_SLAP", null, preload("res://edited_images/icon_slap.png"), null, TAB_SPELL],
015 : ["SPELLBOOK_SOE", null, preload("res://dk_images/keepower_64/sight_std.png"), null, TAB_SPELL],
016 : ["SPELLBOOK_CTA", null, preload("res://dk_images/keepower_64/cta_std.png"), null, TAB_SPELL],
017 : ["SPELLBOOK_CAVI", null, preload("res://dk_images/keepower_64/cavein_std.png"), null, TAB_SPELL],
018 : ["SPELLBOOK_HEAL", null, preload("res://dk_images/keepower_64/heal_std.png"), null, TAB_SPELL],
019 : ["SPELLBOOK_HLDAUD", null, preload("res://dk_images/keepower_64/holdaud_std.png"), null, TAB_SPELL],
020 : ["SPELLBOOK_LIGHTN", null, preload("res://dk_images/keepower_64/lightng_std.png"), null, TAB_SPELL],
021 : ["SPELLBOOK_SPDC", null, preload("res://dk_images/keepower_64/speed_std.png"), null, TAB_SPELL],
022 : ["SPELLBOOK_PROT", null, preload("res://dk_images/keepower_64/armor_std.png"), null, TAB_SPELL],
023 : ["SPELLBOOK_CONCL", null, preload("res://dk_images/keepower_64/conceal_std.png"), null, TAB_SPELL],
024 : ["CTA_ENSIGN", null, null, null, TAB_MISC],
025 : ["ROOM_FLAG", null, null, null, TAB_MISC],
026 : ["ANVIL", null, preload("res://dk_images/furniture/workshop_anvil_tp/r1frame01.png"), null, TAB_FURNITURE],
027 : ["PRISON_BAR", null, preload("res://dk_images/other/anim0797/r1frame01.png"), null, TAB_FURNITURE],
028 : ["CANDLESTCK", null, preload("res://dk_images/furniture/anim0791/r1frame01.png"), null, TAB_DECORATION], #TAB_FURNITURE
029 : ["GRAVE_STONE", null, preload("res://dk_images/furniture/tombstone_tp/r1frame01.png"), null, TAB_FURNITURE],
030 : ["STATUE_HORNY", null, preload("res://dk_images/statues/anim0907/r1frame01.png"), null, TAB_DECORATION], #TAB_FURNITURE
031 : ["TRAINING_POST", null, preload("res://dk_images/furniture/training_machine_tp/AnimTrainingMachine.tres"), null, TAB_FURNITURE],
032 : ["TORTURE_SPIKE", null, preload("res://dk_images/furniture/anim0892/AnimSpike.tres"), null, TAB_FURNITURE],
033 : ["TEMPLE_SPANGLE", null, preload("res://dk_images/magic_fogs/anim0798/AnimTempleSpangle.tres"), null, TAB_DECORATION],
034 : ["POTION_PURPLE", null, preload("res://dk_images/potions/anim0804/r1frame01.png"), null, TAB_DECORATION],
035 : ["POTION_BLUE", null, preload("res://dk_images/potions/anim0806/r1frame01.png"), null, TAB_DECORATION],
036 : ["POTION_GREEN", null, preload("res://dk_images/potions/anim0808/r1frame01.png"), null, TAB_DECORATION],
037 : ["POWER_HAND", null, preload("res://dk_images/power_hand/anim0783/AnimePowerHand.tres"), null, TAB_MISC],
038 : ["POWER_HAND_GRAB", null, preload("res://dk_images/power_hand/anim0784/AnimePowerHandGrab.tres"), null, TAB_MISC],
039 : ["POWER_HAND_WHIP", null, preload("res://dk_images/power_hand/anim0786/AnimePowerHandWhip.tres"), null, TAB_MISC],
040 : ["CHICKEN_STB", null, preload("res://dk_images/food/anim0899/r1frame01.png"), null, TAB_MISC],
041 : ["CHICKEN_WOB", null, preload("res://dk_images/food/anim0900/AnimEggWobbling3.tres"), null, TAB_MISC],
042 : ["CHICKEN_CRK", null, preload("res://dk_images/food/anim0901/AnimEggCracking4.tres"), null, TAB_MISC],
043 : ["GOLDL", null, preload("res://dk_images/valuables/gold_hoard1_tp/AnimGoldHoard1.tres"), null, TAB_GOLD],
044 : ["SPINNING_KEY", null, preload("res://dk_images/traps_doors/anim0811/AnimSpinningKey.tres"), null, TAB_MISC],
045 : ["SPELLBOOK_DISEASE", null, preload("res://dk_images/keepower_64/disease_std.png"), null, TAB_SPELL],
046 : ["SPELLBOOK_CHKN", null, preload("res://dk_images/keepower_64/chicken_std.png"), null, TAB_SPELL],
047 : ["SPELLBOOK_DWAL", null, preload("res://dk_images/keepower_64/dstwall_std.png"), null, TAB_SPELL],
048 : ["SPELLBOOK_TBMB", null, preload("res://edited_images/timebomb.png"), null, TAB_SPELL],
049 : ["HERO_GATE", null, preload("res://dk_images/crucials/anim0780/AnimHeroGate.tres"), null, TAB_ACTION],
050 : ["SPINNING_KEY2", null, preload("res://dk_images/traps_doors/anim0811/AnimSpinningKey.tres"), null, TAB_MISC],
051 : ["ARMOUR", null, null, null, TAB_MISC],
052 : ["GOLD_HOARD_1", null, preload("res://dk_images/valuables/gold_hoard1_tp/AnimGoldHoard1.tres"), null, TAB_GOLD],
053 : ["GOLD_HOARD_2", null, preload("res://dk_images/valuables/gold_hoard2_tp/AnimGoldHoard2.tres"), null, TAB_GOLD],
054 : ["GOLD_HOARD_3", null, preload("res://dk_images/valuables/gold_hoard3_tp/AnimGoldHoard3.tres"), null, TAB_GOLD],
055 : ["GOLD_HOARD_4", null, preload("res://dk_images/valuables/gold_hoard4_tp/AnimGoldHoard4.tres"), null, TAB_GOLD],
056 : ["GOLD_HOARD_5", null, preload("res://dk_images/valuables/gold_hoard5_tp/AnimGoldHoard5.tres"), null, TAB_GOLD],
057 : ["LAIR_WIZRD", null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
058 : ["LAIR_BARBR", null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
059 : ["LAIR_ARCHR", null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
060 : ["LAIR_MONK", null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
061 : ["LAIR_DWRFA", null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
062 : ["LAIR_KNGHT", null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
063 : ["LAIR_AVATR", null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
064 : ["LAIR_TUNLR", null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
065 : ["LAIR_WITCH", null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
066 : ["LAIR_GIANT", null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
067 : ["LAIR_FAIRY", null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
068 : ["LAIR_THIEF", null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
069 : ["LAIR_SAMUR", null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
070 : ["LAIR_HORNY", null, preload("res://edited_images/lair/creature_horny/anim0160/AnimLairHornedReaper.tres"), null, TAB_LAIR],
071 : ["LAIR_SKELT", null, preload("res://edited_images/lair/creature_skeleton/anim0158/AnimLairSkeleton.tres"), null, TAB_LAIR],
072 : ["LAIR_GOBLN", null, preload("res://edited_images/lair/creature_generic/anim0156/r1frame01.png"), null, TAB_LAIR],
073 : ["LAIR_DRAGN", null, preload("res://edited_images/lair/creature_dragon/anim0154/AnimLairDragon.tres"), null, TAB_LAIR],
074 : ["LAIR_DEMSP", null, preload("res://edited_images/lair/creature_demonspawn/lairempty_tp/r1frame01.png"), null, TAB_LAIR],
075 : ["LAIR_FLY", null, preload("res://edited_images/lair/creature_fly/anim0150/AnimLairFly.tres"), null, TAB_LAIR],
076 : ["LAIR_DKMIS", null, preload("res://edited_images/lair/creature_dkmistress/anim0148/AnimLairMistress.tres"), null, TAB_LAIR],
077 : ["LAIR_SORCR", null, preload("res://edited_images/lair/creature_warlock/anim0146/AnimLairWarlock.tres"), null, TAB_LAIR],
078 : ["LAIR_BILDM", null, preload("res://edited_images/lair/creature_biledemon/anim0144/AnimLairBileDemon.tres"), null, TAB_LAIR],
079 : ["LAIR_IMP", null, preload("res://edited_images/lair/creature_dragon/anim0154/r1frame01.png"), null, TAB_LAIR],
080 : ["LAIR_BUG", null, preload("res://edited_images/lair/creature_bug/anim0142/AnimLairBeetle.tres"), null, TAB_LAIR],
081 : ["LAIR_VAMP", null, preload("res://edited_images/lair/creature_vampire/anim0140/r1frame01.png"), null, TAB_LAIR],
082 : ["LAIR_SPIDR", null, preload("res://edited_images/lair/creature_spider/anim0138/AnimLairSpider.tres"), null, TAB_LAIR],
083 : ["LAIR_HLHND", null, preload("res://edited_images/lair/creature_hound/anim0136/r1frame01.png"), null, TAB_LAIR],
084 : ["LAIR_GHOST", null, preload("res://edited_images/lair/creature_ghost/anim0134/r1frame01.png"), null, TAB_LAIR],
085 : ["LAIR_TENTC", null, preload("res://edited_images/lair/creature_tentacle/anim0130/r1frame01.png"), null, TAB_LAIR],
086 : ["SPECBOX_REVMAP", null, preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
087 : ["SPECBOX_RESURCT", null, preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
088 : ["SPECBOX_TRANSFR", null, preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
089 : ["SPECBOX_STEALHR", null, preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
090 : ["SPECBOX_MULTPLY", null, preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
091 : ["SPECBOX_INCLEV", null, preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
092 : ["SPECBOX_MKSAFE", null, preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
093 : ["SPECBOX_HIDNWRL", null, preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
094 : ["WRKBOX_BOULDER", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
095 : ["WRKBOX_ALARM", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
096 : ["WRKBOX_POISONG", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
097 : ["WRKBOX_LIGHTNG", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
098 : ["WRKBOX_WRDOFPW", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
099 : ["WRKBOX_LAVA", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
100 : ["WRKBOX_DEMOLTN", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
101 : ["WRKBOX_DUMMY3", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
102 : ["WRKBOX_DUMMY4", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
103 : ["WRKBOX_DUMMY5", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
104 : ["WRKBOX_DUMMY6", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
105 : ["WRKBOX_DUMMY7", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
106 : ["WRKBOX_WOOD", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
107 : ["WRKBOX_BRACE", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
108 : ["WRKBOX_STEEL", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
109 : ["WRKBOX_MAGIC", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
110 : ["WRKBOX_ITEM", null, preload("res://dk_images/furniture/workshop_anvil_tp/r1frame01.png"), null, TAB_MISC],
111 : ["HEARTFLAME_RED", null, preload("res://dk_images/magic_fogs/anim0801/AnimRedHeartFlame.tres"), null, TAB_FURNITURE],
112 : ["DISEASE", null, null, null, TAB_MISC],
113 : ["SCAVENGE_EYE", null, preload("res://dk_images/furniture/scavenge_eye_tp/AnimScavengerEye.tres"), null, TAB_FURNITURE],
114 : ["WORKSHOP_MACHINE", null, preload("res://dk_images/furniture/workshop_machine_tp/AnimWorkshopMachine.tres"), null, TAB_FURNITURE],
115 : ["GUARDFLAG_RED", null, preload("res://dk_images/furniture/flagpole_redflag_tp/AnimFlagpoleRed.tres"), null, TAB_FURNITURE],
116 : ["GUARDFLAG_BLUE", null, preload("res://dk_images/furniture/flagpole_blueflag_tp/AnimFlagpoleBlue.tres"), null, TAB_FURNITURE],
117 : ["GUARDFLAG_GREEN", null, preload("res://dk_images/furniture/flagpole_greenflag_tp/AnimFlagpoleGreen.tres"), null, TAB_FURNITURE],
118 : ["GUARDFLAG_YELLOW", null, preload("res://dk_images/furniture/flagpole_yellowflag_tp/AnimFlagpoleYellow.tres"), null, TAB_FURNITURE],
119 : ["FLAG_POST", null, preload("res://dk_images/furniture/flagpole_empty_tp/r1frame01.png"), null, TAB_FURNITURE],
120 : ["HEARTFLAME_BLUE", null, preload("res://dk_images/magic_fogs/anim0802/AnimBlueHeartFlame.tres"), null, TAB_FURNITURE],
121 : ["HEARTFLAME_GREEN", null, preload("res://dk_images/magic_fogs/anim0800/AnimGreenHeartFlame.tres"), null, TAB_FURNITURE],
122 : ["HEARTFLAME_YELLOW", null, preload("res://dk_images/magic_fogs/anim0799/AnimYellowHeartFlame.tres"), null, TAB_FURNITURE],
123 : ["POWER_SIGHT", null, preload("res://dk_images/magic_fogs/anim0854/AnimCastedSight.tres"), null, TAB_MISC],
124 : ["POWER_LIGHTNG", null, null, null, TAB_MISC],
125 : ["TORTURER", null, preload("res://dk_images/furniture/torture_machine_tp/r1frame01.png"), null, TAB_FURNITURE],
126 : ["LAIR_ORC", null, preload("res://edited_images/lair/creature_orc/anim0128/r1frame01.png"), null, TAB_LAIR],
127 : ["POWER_HAND_GOLD", null, preload("res://dk_images/power_hand/anim0782/AnimePowerHandGold.tres"), null, TAB_MISC],
128 : ["SPINNCOIN", null, null, null, TAB_MISC],
129 : ["STATUE2", null, preload("res://dk_images/statues/anim0954/r1frame01.png"), null, TAB_DECORATION],
130 : ["STATUE3", null, preload("res://dk_images/statues/anim0956/r1frame01.png"), null, TAB_DECORATION],
131 : ["STATUE4", null, preload("res://dk_images/statues/anim0958/r1frame01.png"), null, TAB_DECORATION],
132 : ["STATUE5", null, preload("res://dk_images/statues/anim0960/r1frame01.png"), null, TAB_DECORATION],
133 : ["SPECBOX_CUSTOM", null, preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
134 : ["SPELLBOOK_ARMG", null, preload("res://dk_images/keepower_64/armagedn_std.png"), null, TAB_SPELL],
135 : ["SPELLBOOK_POSS", null, preload("res://dk_images/keepower_64/possess_std.png"), null, TAB_SPELL],

#136 : ["Gold Bag (100)", null, preload("res://dk_images/valuables/gold_sack_tp/r1frame01.png"), null, TAB_GOLD],
#161 : ["White Flag", null, preload("res://dk_images/furniture/flagpole_whiteflag_tp/AnimFlagpoleWhite.tres"), null, TAB_FURNITURE],
#162 : ["White Heart Flame", null, preload("res://edited_images/heartflames/heartflame_white/AnimWhiteHeartFlame.tres"), null, TAB_FURNITURE],
#164 : ["Purple Flag", null, preload("res://dk_images/furniture/flagpole_purpleflag_tp/AnimFlagpolePurple.tres"), null, TAB_FURNITURE],
#165 : ["Purple Heart Flame", null, preload("res://edited_images/heartflames/heartflame_purple/AnimPurpleHeartFlame.tres"), null, TAB_FURNITURE],
#166 : ["Black Flag", null, preload("res://dk_images/furniture/flagpole_blackflag_tp/AnimFlagpoleBlack.tres"), null, TAB_FURNITURE],
#167 : ["Black Heart Flame", null, preload("res://edited_images/heartflames/heartflame_black/AnimBlackHeartFlame.tres"), null, TAB_FURNITURE],
#168 : ["Orange Flag", null, preload("res://dk_images/furniture/flagpole_orangeflag_tp/AnimFlagpoleOrange.tres"), null, TAB_FURNITURE],
#169 : ["Orange Heart Flame", null, preload("res://edited_images/heartflames/heartflame_orange/AnimOrangeHeartFlame.tres"), null, TAB_FURNITURE],
}

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
