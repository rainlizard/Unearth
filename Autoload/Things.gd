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

var convert_name = {
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
	NAME = 0
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
1 : ["Action Point", null,  preload("res://Art/ActionPoint.png"), null, TAB_ACTION],
2 : ["Light", null, preload("res://edited_images/GUIEDIT-1/PIC26.png"), null, TAB_EFFECTGEN],
}
var DATA_DOOR = { #
0 : [null, null, null, null, null],
1 : ["Wooden Door", null, preload("res://dk_images/trapdoor_64/door_pers_wood_std.png"), null, TAB_MISC],
2 : ["Braced Door", null, preload("res://dk_images/trapdoor_64/door_pers_braced_std.png"), null, TAB_MISC],
3 : ["Iron Door", null, preload("res://dk_images/trapdoor_64/door_pers_iron_std.png"), null, TAB_MISC],
4 : ["Magic Door", null, preload("res://dk_images/trapdoor_64/door_pers_magic_std.png"), null, TAB_MISC]
}
var DATA_TRAP = {
0 : [null, null, null, null, null],
1 : ["Boulder Trap", null, preload("res://dk_images/trapdoor_64/trap_boulder_std.png"), null, TAB_TRAP],
2 : ["Alarm Trap", null, preload("res://dk_images/trapdoor_64/trap_alarm_std.png"), null, TAB_TRAP],
3 : ["Poison Gas Trap", null, preload("res://dk_images/trapdoor_64/trap_gas_std.png"), null, TAB_TRAP],
4 : ["Lightning Trap", null, preload("res://dk_images/trapdoor_64/trap_lightning_std.png"), null, TAB_TRAP],
5 : ["Word of Power Trap", null, preload("res://dk_images/trapdoor_64/trap_wop_std.png"), null, TAB_TRAP],
6 : ["Lava Trap", null, preload("res://dk_images/trapdoor_64/trap_lava_std.png"), null, TAB_TRAP],
7 : ["Dummy Trap 2", null, null, null, TAB_TRAP],
8 : ["Dummy Trap 3", null, null, null, null, TAB_TRAP],
9 : ["Dummy Trap 4", null, null, null, null, TAB_TRAP],
10 : ["Dummy Trap 5", null, null, null, null, TAB_TRAP],
11 : ["Dummy Trap 6", null, null, null, null, TAB_TRAP],
12 : ["Dummy Trap 7", null, null, null, null, TAB_TRAP],
}

var DATA_EFFECTGEN = {
0 : [null, null, null, null, null],
1 : ["Lava Effect", null, preload("res://edited_images/GUIEDIT-1/PIC27.png"), null, TAB_EFFECTGEN],
2 : ["Dripping Water Effect", null, preload("res://edited_images/GUIEDIT-1/PIC28.png"), null, TAB_EFFECTGEN],
3 : ["Rock Fall Effect", null, preload("res://edited_images/GUIEDIT-1/PIC29.png"), null, TAB_EFFECTGEN],
4 : ["Entrance Ice Effect", null, preload("res://edited_images/GUIEDIT-1/PIC30.png"), null, TAB_EFFECTGEN],
5 : ["Dry Ice Effect", null, preload("res://edited_images/GUIEDIT-1/PIC31.png"), null, TAB_EFFECTGEN]
}
var DATA_CREATURE = {
00 : [null, null, null, null, null],
01 : ["Wizard", null,          preload("res://edited_images/creatr_icon_64/wizrd_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_wizrd.png"), TAB_CREATURE],
02 : ["Barbarian", null,       preload("res://edited_images/creatr_icon_64/barbr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_barbr.png"), TAB_CREATURE],
03 : ["Archer", null,          preload("res://edited_images/creatr_icon_64/archr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_archr.png"), TAB_CREATURE],
04 : ["Monk", null,            preload("res://edited_images/creatr_icon_64/monk_std.png"),  preload("res://dk_images/creature_portrait_64/creatr_portrt_monk.png"), TAB_CREATURE],
05 : ["Dwarf", null,           preload("res://edited_images/creatr_icon_64/dwarf_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_dwrf1.png"), TAB_CREATURE],
06 : ["Knight", null,          preload("res://edited_images/creatr_icon_64/knght_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_knigh.png"), TAB_CREATURE],
07 : ["Avatar", null,          preload("res://edited_images/creatr_icon_64/avatr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_avatr.png"), TAB_CREATURE],
08 : ["Tunneller", null,       preload("res://edited_images/creatr_icon_64/tunlr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_dwrf2.png"), TAB_CREATURE],
09 : ["Witch", null,           preload("res://edited_images/creatr_icon_64/prsts_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_witch.png"), TAB_CREATURE],
10 : ["Giant", null,           preload("res://edited_images/creatr_icon_64/giant_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_giant.png"), TAB_CREATURE],
11 : ["Fairy", null,           preload("res://edited_images/creatr_icon_64/fairy_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_fairy.png"), TAB_CREATURE],
12 : ["Thief", null,           preload("res://edited_images/creatr_icon_64/thief_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_thief.png"), TAB_CREATURE],
13 : ["Samurai", null,         preload("res://edited_images/creatr_icon_64/samur_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_samur.png"), TAB_CREATURE],
14 : ["Horned Reaper", null,   preload("res://edited_images/creatr_icon_64/hornd_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_horny.png"), TAB_CREATURE],
15 : ["Skeleton", null,        preload("res://edited_images/creatr_icon_64/skelt_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_skelt.png"), TAB_CREATURE],
16 : ["Troll", null,           preload("res://edited_images/creatr_icon_64/troll_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_troll.png"), TAB_CREATURE],
17 : ["Dragon", null,          preload("res://edited_images/creatr_icon_64/dragn_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_dragn.png"), TAB_CREATURE],
18 : ["Demon Spawn", null,     preload("res://edited_images/creatr_icon_64/dspwn_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_spawn.png"), TAB_CREATURE],
19 : ["Fly", null,             preload("res://edited_images/creatr_icon_64/fly_std.png"),   preload("res://dk_images/creature_portrait_64/creatr_portrt_fly.png"), TAB_CREATURE],
20 : ["Dark Mistress", null,   preload("res://edited_images/creatr_icon_64/dkmis_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_mistr.png"), TAB_CREATURE],
21 : ["Warlock", null,         preload("res://edited_images/creatr_icon_64/warlk_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_warlk.png"), TAB_CREATURE],
22 : ["Bile Demon", null,      preload("res://edited_images/creatr_icon_64/biled_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_biled.png"), TAB_CREATURE],
23 : ["Imp", null,             preload("res://edited_images/creatr_icon_64/imp_std.png"),   preload("res://dk_images/creature_portrait_64/creatr_portrt_imp.png"), TAB_CREATURE],
24 : ["Beetle", null,          preload("res://edited_images/creatr_icon_64/bug_std.png"),   preload("res://dk_images/creature_portrait_64/creatr_portrt_bug.png"), TAB_CREATURE],
25 : ["Vampire", null,         preload("res://edited_images/creatr_icon_64/vampr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_vampr.png"), TAB_CREATURE],
26 : ["Spider", null,          preload("res://edited_images/creatr_icon_64/spidr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_spidr.png"), TAB_CREATURE],
27 : ["Hell Hound", null,      preload("res://edited_images/creatr_icon_64/hound_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_hound.png"), TAB_CREATURE],
28 : ["Ghost", null,           preload("res://edited_images/creatr_icon_64/ghost_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_ghost.png"), TAB_CREATURE],
29 : ["Tentacle", null,        preload("res://edited_images/creatr_icon_64/tentc_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_tentc.png"), TAB_CREATURE],
30 : ["Orc", null,             preload("res://edited_images/creatr_icon_64/orc_std.png"),   preload("res://dk_images/creature_portrait_64/creatr_portrt_orc.png"), TAB_CREATURE],
31 : ["Floating Spirit", null, preload("res://dk_images/magic_dust/anim0981/r1frame02.png"), preload("res://dk_images/magic_dust/anim0981/r1frame02.png"), TAB_CREATURE] # wrong icon probably
}

var DATA_OBJECT = {
000 : [null, null, null, null, null],
001 : ["Barrel", null, preload("res://dk_images/other/anim0932/r1frame01.png"), null, TAB_DECORATION],
002 : ["Torch", null, preload("res://dk_images/other/anim0963/r1frame01.png"), null, TAB_DECORATION], #TAB_FURNITURE
003 : ["Gold Pot (500)", null, preload("res://dk_images/valuables/gold_pot_tp/AnimGoldPot.tres"), null, TAB_GOLD],
004 : ["Lit Statue", null, preload("res://dk_images/statues/anim0952/AnimLitStatue.tres"), null, TAB_DECORATION], #TAB_FURNITURE
005 : ["Dungeon Heart", null, preload("res://dk_images/crucials/anim0950/AnimDungeonHeart.tres"), null, TAB_FURNITURE],
006 : ["Gold Pot (250)", null, preload("res://dk_images/valuables/gold_pot_tp/AnimGoldPot.tres"), null, TAB_GOLD],
007 : ["Unlit Torch", null, preload("res://dk_images/other/anim0963/r1frame01.png"), null, TAB_DECORATION], #TAB_FURNITURE
008 : ["Glowing Statue", null, preload("res://dk_images/statues/anim0952/AnimLitStatue.tres"), null, TAB_DECORATION], #Lit Statue No Flame # Partially Lit Statue
009 : ["Egg Growing (1)", null, preload("res://dk_images/food/anim0898/AnimEggGrowing1.tres"), null, TAB_MISC],
010 : ["Chicken", null, preload("res://dk_images/food/anim0822/AnimChicken.tres"), null, TAB_MISC],
011 : ["Hand Of Evil", null, preload("res://edited_images/icon_handofevil.png"), null, TAB_SPELL],
012 : ["Create Imp", null, preload("res://dk_images/keepower_64/imp_std.png"), null, TAB_SPELL],
013 : ["Must Obey", null, preload("res://edited_images/mustobey.png"), null, TAB_SPELL],
014 : ["Slap", null, preload("res://edited_images/icon_slap.png"), null, TAB_SPELL],
015 : ["Sight of Evil", null, preload("res://dk_images/keepower_64/sight_std.png"), null, TAB_SPELL],
016 : ["Call To Arms", null, preload("res://dk_images/keepower_64/cta_std.png"), null, TAB_SPELL],
017 : ["Cave-In", null, preload("res://dk_images/keepower_64/cavein_std.png"), null, TAB_SPELL],
018 : ["Heal", null, preload("res://dk_images/keepower_64/heal_std.png"), null, TAB_SPELL],
019 : ["Hold Audience", null, preload("res://dk_images/keepower_64/holdaud_std.png"), null, TAB_SPELL],
020 : ["Lightning Strike", null, preload("res://dk_images/keepower_64/lightng_std.png"), null, TAB_SPELL],
021 : ["Speed Monster", null, preload("res://dk_images/keepower_64/speed_std.png"), null, TAB_SPELL],
022 : ["Protect Monster", null, preload("res://dk_images/keepower_64/armor_std.png"), null, TAB_SPELL],
023 : ["Conceal Monster", null, preload("res://dk_images/keepower_64/conceal_std.png"), null, TAB_SPELL],
024 : ["Cta Ensign", null, null, null, TAB_MISC],
025 : ["Room Flag", null, null, null, TAB_MISC],
026 : ["Anvil", null, preload("res://dk_images/furniture/workshop_anvil_tp/r1frame01.png"), null, TAB_FURNITURE],
027 : ["Prison Bar", null, preload("res://dk_images/other/anim0797/r1frame01.png"), null, TAB_FURNITURE],
028 : ["Candlestick", null, preload("res://dk_images/furniture/anim0791/r1frame01.png"), null, TAB_DECORATION], #TAB_FURNITURE
029 : ["Gravestone", null, preload("res://dk_images/furniture/tombstone_tp/r1frame01.png"), null, TAB_FURNITURE],
030 : ["Aztec Statue", null, preload("res://dk_images/statues/anim0907/r1frame01.png"), null, TAB_DECORATION], #TAB_FURNITURE
031 : ["Training Post", null, preload("res://dk_images/furniture/training_machine_tp/AnimTrainingMachine.tres"), null, TAB_FURNITURE],
032 : ["Torture Spike", null, preload("res://dk_images/furniture/anim0892/AnimSpike.tres"), null, TAB_FURNITURE],
033 : ["Temple Spangle", null, preload("res://dk_images/magic_fogs/anim0798/AnimTempleSpangle.tres"), null, TAB_DECORATION],
034 : ["Purple Potion", null, preload("res://dk_images/potions/anim0804/r1frame01.png"), null, TAB_DECORATION],
035 : ["Blue Potion", null, preload("res://dk_images/potions/anim0806/r1frame01.png"), null, TAB_DECORATION],
036 : ["Green Potion", null, preload("res://dk_images/potions/anim0808/r1frame01.png"), null, TAB_DECORATION],
037 : ["Power Hand", null, preload("res://dk_images/power_hand/anim0783/AnimePowerHand.tres"), null, TAB_MISC],
038 : ["Power Hand Grab", null, preload("res://dk_images/power_hand/anim0784/AnimePowerHandGrab.tres"), null, TAB_MISC],
039 : ["Power Hand Whip", null, preload("res://dk_images/power_hand/anim0786/AnimePowerHandWhip.tres"), null, TAB_MISC],
040 : ["Egg Stable (2)", null, preload("res://dk_images/food/anim0899/r1frame01.png"), null, TAB_MISC],
041 : ["Egg Wobbling (3)", null, preload("res://dk_images/food/anim0900/AnimEggWobbling3.tres"), null, TAB_MISC],
042 : ["Egg Cracking (4)", null, preload("res://dk_images/food/anim0901/AnimEggCracking4.tres"), null, TAB_MISC],
043 : ["Gold Pile (200)", null, preload("res://dk_images/valuables/gold_hoard1_tp/AnimGoldHoard1.tres"), null, TAB_GOLD],
044 : ["Spinning Key", null, preload("res://dk_images/traps_doors/anim0811/AnimSpinningKey.tres"), null, TAB_MISC],
045 : ["Disease", null, preload("res://dk_images/keepower_64/disease_std.png"), null, TAB_SPELL],
046 : ["Chicken Spell", null, preload("res://dk_images/keepower_64/chicken_std.png"), null, TAB_SPELL],
047 : ["Destroy Walls", null, preload("res://dk_images/keepower_64/dstwall_std.png"), null, TAB_SPELL],
048 : ["Time Bomb", null, preload("res://edited_images/timebomb.png"), null, TAB_SPELL], 
049 : ["Hero Gate", null, preload("res://dk_images/crucials/anim0780/AnimHeroGate.tres"), null, TAB_ACTION],
050 : ["Spinning Key 2", null, preload("res://dk_images/traps_doors/anim0811/AnimSpinningKey.tres"), null, TAB_MISC],
051 : ["Armour Effect", null, null, null, TAB_MISC],
052 : ["Treasury Hoard 1 (400)", null, preload("res://dk_images/valuables/gold_hoard1_tp/AnimGoldHoard1.tres"), null, TAB_GOLD],
053 : ["Treasury Hoard 2 (800)", null, preload("res://dk_images/valuables/gold_hoard2_tp/AnimGoldHoard2.tres"), null, TAB_GOLD],
054 : ["Treasury Hoard 3 (1200)", null, preload("res://dk_images/valuables/gold_hoard3_tp/AnimGoldHoard3.tres"), null, TAB_GOLD],
055 : ["Treasury Hoard 4 (1600)", null, preload("res://dk_images/valuables/gold_hoard4_tp/AnimGoldHoard4.tres"), null, TAB_GOLD],
056 : ["Treasury Hoard 5 (2000)", null, preload("res://dk_images/valuables/gold_hoard5_tp/AnimGoldHoard5.tres"), null, TAB_GOLD],
057 : ["Wizard Lair", null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
058 : ["Barbarian Lair", null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
059 : ["Archer Lair", null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
060 : ["Monk Lair", null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
061 : ["Dwarf Lair", null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
062 : ["Knight Lair", null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
063 : ["Avatar Lair", null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
064 : ["Tunneller Lair", null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
065 : ["Witch Lair", null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
066 : ["Giant Lair", null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
067 : ["Fairy Lair", null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
068 : ["Thief Lair", null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
069 : ["Samurai Lair", null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
070 : ["Horned Reaper Lair", null, preload("res://edited_images/lair/creature_horny/anim0160/AnimLairHornedReaper.tres"), null, TAB_LAIR],
071 : ["Skeleton Lair", null, preload("res://edited_images/lair/creature_skeleton/anim0158/AnimLairSkeleton.tres"), null, TAB_LAIR],
072 : ["Troll Lair", null, preload("res://edited_images/lair/creature_generic/anim0156/r1frame01.png"), null, TAB_LAIR],
073 : ["Dragon Lair", null, preload("res://edited_images/lair/creature_dragon/anim0154/AnimLairDragon.tres"), null, TAB_LAIR],
074 : ["Demon Spawn Lair", null, preload("res://edited_images/lair/creature_demonspawn/lairempty_tp/r1frame01.png"), null, TAB_LAIR],
075 : ["Fly Lair", null, preload("res://edited_images/lair/creature_fly/anim0150/AnimLairFly.tres"), null, TAB_LAIR],
076 : ["Mistress Lair", null, preload("res://edited_images/lair/creature_dkmistress/anim0148/AnimLairMistress.tres"), null, TAB_LAIR],
077 : ["Warlock Lair", null, preload("res://edited_images/lair/creature_warlock/anim0146/AnimLairWarlock.tres"), null, TAB_LAIR],
078 : ["Bile Demon Lair", null, preload("res://edited_images/lair/creature_biledemon/anim0144/AnimLairBileDemon.tres"), null, TAB_LAIR],
079 : ["Imp Lair", null, preload("res://edited_images/lair/creature_dragon/anim0154/r1frame01.png"), null, TAB_LAIR],
080 : ["Beetle Lair", null, preload("res://edited_images/lair/creature_bug/anim0142/AnimLairBeetle.tres"), null, TAB_LAIR],
081 : ["Vampire Lair", null, preload("res://edited_images/lair/creature_vampire/anim0140/r1frame01.png"), null, TAB_LAIR],
082 : ["Spider Lair", null, preload("res://edited_images/lair/creature_spider/anim0138/AnimLairSpider.tres"), null, TAB_LAIR],
083 : ["Hell Hound Lair", null, preload("res://edited_images/lair/creature_hound/anim0136/r1frame01.png"), null, TAB_LAIR],
084 : ["Ghost Lair", null, preload("res://edited_images/lair/creature_ghost/anim0134/r1frame01.png"), null, TAB_LAIR],
085 : ["Tentacle Lair", null, preload("res://edited_images/lair/creature_tentacle/anim0130/r1frame01.png"), null, TAB_LAIR],
086 : ["Reveal Map", null, preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
087 : ["Resurrect Creature", null, preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
088 : ["Transfer Creature", null, preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
089 : ["Steal Hero", null, preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
090 : ["Multiply Creatures", null, preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
091 : ["Increase Level", null, preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
092 : ["Make Safe", null, preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
093 : ["Locate Hidden World", null, preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
094 : ["Box: Boulder Trap", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
095 : ["Box: Alarm Trap", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
096 : ["Box: Poison Gas Trap", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
097 : ["Box: Lightning Trap", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
098 : ["Box: Word of Power Trap", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
099 : ["Box: Lava Trap", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
100 : ["Box: Dummy Trap 2", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
101 : ["Box: Dummy Trap 3", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
102 : ["Box: Dummy Trap 4", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
103 : ["Box: Dummy Trap 5", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
104 : ["Box: Dummy Trap 6", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
105 : ["Box: Dummy Trap 7", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
106 : ["Box: Wooden Door", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
107 : ["Box: Braced Door", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
108 : ["Box: Iron Door", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
109 : ["Box: Magic Door", null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
110 : ["Workshop Item", null, preload("res://dk_images/furniture/workshop_anvil_tp/r1frame01.png"), null, TAB_MISC],
111 : ["Red Heart Flame", null, preload("res://dk_images/magic_fogs/anim0801/AnimRedHeartFlame.tres"), null, TAB_FURNITURE],
112 : ["Disease Effect", null, null, null, TAB_MISC],
113 : ["Scavenger Eye", null, preload("res://dk_images/furniture/scavenge_eye_tp/AnimScavengerEye.tres"), null, TAB_FURNITURE],
114 : ["Workshop Machine", null, preload("res://dk_images/furniture/workshop_machine_tp/AnimWorkshopMachine.tres"), null, TAB_FURNITURE],
115 : ["Red Flag", null, preload("res://dk_images/furniture/flagpole_redflag_tp/AnimFlagpoleRed.tres"), null, TAB_FURNITURE],
116 : ["Blue Flag", null, preload("res://dk_images/furniture/flagpole_blueflag_tp/AnimFlagpoleBlue.tres"), null, TAB_FURNITURE],
117 : ["Green Flag", null, preload("res://dk_images/furniture/flagpole_greenflag_tp/AnimFlagpoleGreen.tres"), null, TAB_FURNITURE],
118 : ["Yellow Flag", null, preload("res://dk_images/furniture/flagpole_yellowflag_tp/AnimFlagpoleYellow.tres"), null, TAB_FURNITURE],
119 : ["Flagpole", null, preload("res://dk_images/furniture/flagpole_empty_tp/r1frame01.png"), null, TAB_FURNITURE],
120 : ["Blue Heart Flame", null, preload("res://dk_images/magic_fogs/anim0802/AnimBlueHeartFlame.tres"), null, TAB_FURNITURE],
121 : ["Green Heart Flame", null, preload("res://dk_images/magic_fogs/anim0800/AnimGreenHeartFlame.tres"), null, TAB_FURNITURE],
122 : ["Yellow Heart Flame", null, preload("res://dk_images/magic_fogs/anim0799/AnimYellowHeartFlame.tres"), null, TAB_FURNITURE],
123 : ["Casted Sight", null, preload("res://dk_images/magic_fogs/anim0854/AnimCastedSight.tres"), null, TAB_MISC],
124 : ["Casted Lightning", null, null, null, TAB_MISC],
125 : ["Torturer", null, preload("res://dk_images/furniture/torture_machine_tp/r1frame01.png"), null, TAB_FURNITURE],
126 : ["Orc Lair", null, preload("res://edited_images/lair/creature_orc/anim0128/r1frame01.png"), null, TAB_LAIR],
127 : ["Power Hand Gold", null, preload("res://dk_images/power_hand/anim0782/AnimePowerHandGold.tres"), null, TAB_MISC],
128 : ["Spinning Coin", null, null, null, TAB_MISC],
129 : ["Unlit Statue", null, preload("res://dk_images/statues/anim0954/r1frame01.png"), null, TAB_DECORATION],
130 : ["Statue 3", null, preload("res://dk_images/statues/anim0956/r1frame01.png"), null, TAB_DECORATION],
131 : ["Statue 4", null, preload("res://dk_images/statues/anim0958/r1frame01.png"), null, TAB_DECORATION],
132 : ["Statue 5", null, preload("res://dk_images/statues/anim0960/r1frame01.png"), null, TAB_DECORATION],
133 : ["Mysterious Box", null, preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
134 : ["Armageddon Spell", null, preload("res://dk_images/keepower_64/armagedn_std.png"), null, TAB_SPELL],
135 : ["Possess Spell", null, preload("res://dk_images/keepower_64/possess_std.png"), null, TAB_SPELL],

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
