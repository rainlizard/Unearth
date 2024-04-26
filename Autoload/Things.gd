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
	KEEPERFX_NAME = 1
	ANIMATION_ID = 2
	TEXTURE = 3
	PORTRAIT = 4 # Keep PORTAIT field "null" if I want to use texture for portrait.
	EDITOR_TAB = 5
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

var animation_id_to_image = {} # Just a shortcut, the real images are stored in the data structures

var custom_images_list = {} # Contains uppercase filename and real filename

var default_data = {}

func _init():
	# This only takes 1ms
	default_data["DATA_EXTRA"] = DATA_EXTRA.duplicate(true)
	default_data["DATA_DOOR"] = DATA_DOOR.duplicate(true)
	default_data["DATA_TRAP"] = DATA_TRAP.duplicate(true)
	default_data["DATA_EFFECTGEN"] = DATA_EFFECTGEN.duplicate(true)
	default_data["DATA_CREATURE"] = DATA_CREATURE.duplicate(true)
	default_data["DATA_OBJECT"] = DATA_OBJECT.duplicate(true)


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

var DATA_EXTRA = {
0 : [null, null, null, null, null, null],
1 : ["Action Point", null, null,  preload("res://Art/ActionPoint.png"), null, TAB_ACTION],
2 : ["Light", null, null, preload("res://edited_images/GUIEDIT-1/PIC26.png"), null, TAB_EFFECTGEN],
}
var DATA_DOOR = { #
0 : [null, null, null, null, null, null],
1 : ["Wooden Door", null, null, preload("res://dk_images/trapdoor_64/door_pers_wood_std.png"), null, TAB_MISC],
2 : ["Braced Door", null, null, preload("res://dk_images/trapdoor_64/door_pers_braced_std.png"), null, TAB_MISC],
3 : ["Iron Door", null, null, preload("res://dk_images/trapdoor_64/door_pers_iron_std.png"), null, TAB_MISC],
4 : ["Magic Door", null, null, preload("res://dk_images/trapdoor_64/door_pers_magic_std.png"), null, TAB_MISC]
}
var DATA_TRAP = {
0 : [null, null, null, null, null, null],
1 : ["Boulder Trap", null, null, preload("res://dk_images/trapdoor_64/trap_boulder_std.png"), null, TAB_TRAP],
2 : ["Alarm Trap", null, null, preload("res://dk_images/trapdoor_64/trap_alarm_std.png"), null, TAB_TRAP],
3 : ["Poison Gas Trap", null, null, preload("res://dk_images/trapdoor_64/trap_gas_std.png"), null, TAB_TRAP],
4 : ["Lightning Trap", null, null, preload("res://dk_images/trapdoor_64/trap_lightning_std.png"), null, TAB_TRAP],
5 : ["Word of Power Trap", null, null, preload("res://dk_images/trapdoor_64/trap_wop_std.png"), null, TAB_TRAP],
6 : ["Lava Trap", null, null, preload("res://dk_images/trapdoor_64/trap_lava_std.png"), null, TAB_TRAP],
7 : ["Dummy Trap 2", null, null, null, null, TAB_TRAP],
8 : ["Dummy Trap 3", null, null, null, null, TAB_TRAP],
9 : ["Dummy Trap 4", null, null, null, null, TAB_TRAP],
10 : ["Dummy Trap 5", null, null, null, null, TAB_TRAP],
11 : ["Dummy Trap 6", null, null, null, null, TAB_TRAP],
12 : ["Dummy Trap 7", null, null, null, null, TAB_TRAP],
}
var DATA_EFFECTGEN = {
0 : [null, null, null, null, null, null],
1 : ["Effect: Lava", null, null, preload("res://edited_images/GUIEDIT-1/PIC27.png"), null, TAB_EFFECTGEN],
2 : ["Effect: Dripping Water", null, null, preload("res://edited_images/GUIEDIT-1/PIC28.png"), null, TAB_EFFECTGEN],
3 : ["Effect: Rock Fall", null, null, preload("res://edited_images/GUIEDIT-1/PIC29.png"), null, TAB_EFFECTGEN],
4 : ["Effect: Entrance Ice", null, null, preload("res://edited_images/GUIEDIT-1/PIC30.png"), null, TAB_EFFECTGEN],
5 : ["Effect: Dry Ice", null, null, preload("res://edited_images/GUIEDIT-1/PIC31.png"), null, TAB_EFFECTGEN]
}
var DATA_CREATURE = {
00 : [null, null, null, null, null, null],
01 : ["Wizard", null, null,          preload("res://edited_images/creatr_icon_64/wizrd_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_wizrd.png"), TAB_CREATURE],
02 : ["Barbarian", null, null,       preload("res://edited_images/creatr_icon_64/barbr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_barbr.png"), TAB_CREATURE],
03 : ["Archer", null, null,          preload("res://edited_images/creatr_icon_64/archr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_archr.png"), TAB_CREATURE],
04 : ["Monk", null, null,            preload("res://edited_images/creatr_icon_64/monk_std.png"),  preload("res://dk_images/creature_portrait_64/creatr_portrt_monk.png"), TAB_CREATURE],
05 : ["Dwarf", null, null,           preload("res://edited_images/creatr_icon_64/dwarf_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_dwrf1.png"), TAB_CREATURE],
06 : ["Knight", null, null,          preload("res://edited_images/creatr_icon_64/knght_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_knigh.png"), TAB_CREATURE],
07 : ["Avatar", null, null,          preload("res://edited_images/creatr_icon_64/avatr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_avatr.png"), TAB_CREATURE],
08 : ["Tunneller", null, null,       preload("res://edited_images/creatr_icon_64/tunlr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_dwrf2.png"), TAB_CREATURE],
09 : ["Witch", null, null,           preload("res://edited_images/creatr_icon_64/prsts_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_witch.png"), TAB_CREATURE],
10 : ["Giant", null, null,           preload("res://edited_images/creatr_icon_64/giant_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_giant.png"), TAB_CREATURE],
11 : ["Fairy", null, null,           preload("res://edited_images/creatr_icon_64/fairy_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_fairy.png"), TAB_CREATURE],
12 : ["Thief", null, null,           preload("res://edited_images/creatr_icon_64/thief_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_thief.png"), TAB_CREATURE],
13 : ["Samurai", null, null,         preload("res://edited_images/creatr_icon_64/samur_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_samur.png"), TAB_CREATURE],
14 : ["Horned Reaper", null, null,   preload("res://edited_images/creatr_icon_64/hornd_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_horny.png"), TAB_CREATURE],
15 : ["Skeleton", null, null,        preload("res://edited_images/creatr_icon_64/skelt_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_skelt.png"), TAB_CREATURE],
16 : ["Troll", null, null,           preload("res://edited_images/creatr_icon_64/troll_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_troll.png"), TAB_CREATURE],
17 : ["Dragon", null, null,          preload("res://edited_images/creatr_icon_64/dragn_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_dragn.png"), TAB_CREATURE],
18 : ["Demon Spawn", null, null,     preload("res://edited_images/creatr_icon_64/dspwn_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_spawn.png"), TAB_CREATURE],
19 : ["Fly", null, null,             preload("res://edited_images/creatr_icon_64/fly_std.png"),   preload("res://dk_images/creature_portrait_64/creatr_portrt_fly.png"), TAB_CREATURE],
20 : ["Dark Mistress", null, null,   preload("res://edited_images/creatr_icon_64/dkmis_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_mistr.png"), TAB_CREATURE],
21 : ["Warlock", null, null,         preload("res://edited_images/creatr_icon_64/warlk_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_warlk.png"), TAB_CREATURE],
22 : ["Bile Demon", null, null,      preload("res://edited_images/creatr_icon_64/biled_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_biled.png"), TAB_CREATURE],
23 : ["Imp", null, null,             preload("res://edited_images/creatr_icon_64/imp_std.png"),   preload("res://dk_images/creature_portrait_64/creatr_portrt_imp.png"), TAB_CREATURE],
24 : ["Beetle", null, null,          preload("res://edited_images/creatr_icon_64/bug_std.png"),   preload("res://dk_images/creature_portrait_64/creatr_portrt_bug.png"), TAB_CREATURE],
25 : ["Vampire", null, null,         preload("res://edited_images/creatr_icon_64/vampr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_vampr.png"), TAB_CREATURE],
26 : ["Spider", null, null,          preload("res://edited_images/creatr_icon_64/spidr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_spidr.png"), TAB_CREATURE],
27 : ["Hell Hound", null, null,      preload("res://edited_images/creatr_icon_64/hound_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_hound.png"), TAB_CREATURE],
28 : ["Ghost", null, null,           preload("res://edited_images/creatr_icon_64/ghost_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_ghost.png"), TAB_CREATURE],
29 : ["Tentacle", null, null,        preload("res://edited_images/creatr_icon_64/tentc_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_tentc.png"), TAB_CREATURE],
30 : ["Orc", null, null,             preload("res://edited_images/creatr_icon_64/orc_std.png"),   preload("res://dk_images/creature_portrait_64/creatr_portrt_orc.png"), TAB_CREATURE],
31 : ["Floating Spirit", null, null, preload("res://dk_images/magic_dust/anim0981/r1frame02.png"), preload("res://dk_images/magic_dust/anim0981/r1frame02.png"), TAB_CREATURE] # wrong icon probably
}

var DATA_OBJECT = {
000 : [null, null, null, null, null, null],
001 : ["Barrel", null,null, preload("res://dk_images/other/anim0932/r1frame01.png"), null, TAB_DECORATION],
002 : ["Torch", null,null, preload("res://dk_images/other/anim0963/r1frame01.png"), null, TAB_DECORATION], #TAB_FURNITURE
003 : ["Gold Pot (500)", null,null, preload("res://dk_images/valuables/gold_pot_tp/AnimGoldPot.tres"), null, TAB_GOLD],
004 : ["Lit Statue", null,null, preload("res://dk_images/statues/anim0952/AnimLitStatue.tres"), null, TAB_DECORATION], #TAB_FURNITURE
005 : ["Dungeon Heart", null,null, preload("res://dk_images/crucials/anim0950/AnimDungeonHeart.tres"), null, TAB_FURNITURE],
006 : ["Gold Pot (250)", null,null, preload("res://dk_images/valuables/gold_pot_tp/AnimGoldPot.tres"), null, TAB_GOLD],
007 : ["Unlit Torch", null,null, preload("res://dk_images/other/anim0963/r1frame01.png"), null, TAB_DECORATION], #TAB_FURNITURE
008 : ["Glowing Statue", null,null, preload("res://dk_images/statues/anim0952/AnimLitStatue.tres"), null, TAB_DECORATION], #Lit Statue No Flame # Partially Lit Statue
009 : ["Egg Growing (1)", null,null, preload("res://dk_images/food/anim0898/AnimEggGrowing1.tres"), null, TAB_MISC],
010 : ["Chicken", null,null, preload("res://dk_images/food/anim0822/AnimChicken.tres"), null, TAB_MISC],
011 : ["Hand Of Evil", null,null, preload("res://edited_images/icon_handofevil.png"), null, TAB_SPELL],
012 : ["Create Imp", null,null, preload("res://dk_images/keepower_64/imp_std.png"), null, TAB_SPELL],
013 : ["Must Obey", null,null, preload("res://edited_images/mustobey.png"), null, TAB_SPELL],
014 : ["Slap", null,null, preload("res://edited_images/icon_slap.png"), null, TAB_SPELL],
015 : ["Sight of Evil", null,null, preload("res://dk_images/keepower_64/sight_std.png"), null, TAB_SPELL],
016 : ["Call To Arms", null,null, preload("res://dk_images/keepower_64/cta_std.png"), null, TAB_SPELL],
017 : ["Cave-In", null,null, preload("res://dk_images/keepower_64/cavein_std.png"), null, TAB_SPELL],
018 : ["Heal", null,null, preload("res://dk_images/keepower_64/heal_std.png"), null, TAB_SPELL],
019 : ["Hold Audience", null,null, preload("res://dk_images/keepower_64/holdaud_std.png"), null, TAB_SPELL],
020 : ["Lightning Strike", null,null, preload("res://dk_images/keepower_64/lightng_std.png"), null, TAB_SPELL],
021 : ["Speed Monster", null,null, preload("res://dk_images/keepower_64/speed_std.png"), null, TAB_SPELL],
022 : ["Protect Monster", null,null, preload("res://dk_images/keepower_64/armor_std.png"), null, TAB_SPELL],
023 : ["Conceal Monster", null,null, preload("res://dk_images/keepower_64/conceal_std.png"), null, TAB_SPELL],
024 : ["Cta Ensign", null,null, null, null, TAB_MISC],
025 : ["Room Flag", null,null, null, null, TAB_MISC],
026 : ["Anvil", null,null, preload("res://dk_images/furniture/workshop_anvil_tp/r1frame01.png"), null, TAB_FURNITURE],
027 : ["Prison Bar", null,null, preload("res://dk_images/other/anim0797/r1frame01.png"), null, TAB_FURNITURE],
028 : ["Candlestick", null,null, preload("res://dk_images/furniture/anim0791/r1frame01.png"), null, TAB_DECORATION], #TAB_FURNITURE
029 : ["Gravestone", null,null, preload("res://dk_images/furniture/tombstone_tp/r1frame01.png"), null, TAB_FURNITURE],
030 : ["Aztec Statue", null,null, preload("res://dk_images/statues/anim0907/r1frame01.png"), null, TAB_DECORATION], #TAB_FURNITURE
031 : ["Training Post", null,null, preload("res://dk_images/furniture/training_machine_tp/AnimTrainingMachine.tres"), null, TAB_FURNITURE],
032 : ["Torture Spike", null,null, preload("res://dk_images/furniture/anim0892/AnimSpike.tres"), null, TAB_FURNITURE],
033 : ["Temple Spangle", null,null, preload("res://dk_images/magic_fogs/anim0798/AnimTempleSpangle.tres"), null, TAB_DECORATION],
034 : ["Purple Potion", null,null, preload("res://dk_images/potions/anim0804/r1frame01.png"), null, TAB_DECORATION],
035 : ["Blue Potion", null,null, preload("res://dk_images/potions/anim0806/r1frame01.png"), null, TAB_DECORATION],
036 : ["Green Potion", null,null, preload("res://dk_images/potions/anim0808/r1frame01.png"), null, TAB_DECORATION],
037 : ["Power Hand", null,null, preload("res://dk_images/power_hand/anim0783/AnimePowerHand.tres"), null, TAB_MISC],
038 : ["Power Hand Grab", null,null, preload("res://dk_images/power_hand/anim0784/AnimePowerHandGrab.tres"), null, TAB_MISC],
039 : ["Power Hand Whip", null,null, preload("res://dk_images/power_hand/anim0786/AnimePowerHandWhip.tres"), null, TAB_MISC],
040 : ["Egg Stable (2)", null,null, preload("res://dk_images/food/anim0899/r1frame01.png"), null, TAB_MISC],
041 : ["Egg Wobbling (3)", null,null, preload("res://dk_images/food/anim0900/AnimEggWobbling3.tres"), null, TAB_MISC],
042 : ["Egg Cracking (4)", null,null, preload("res://dk_images/food/anim0901/AnimEggCracking4.tres"), null, TAB_MISC],
043 : ["Gold Pile (200)", null,null, preload("res://dk_images/valuables/gold_hoard1_tp/AnimGoldHoard1.tres"), null, TAB_GOLD],
044 : ["Spinning Key", null,null, preload("res://dk_images/traps_doors/anim0811/AnimSpinningKey.tres"), null, TAB_MISC],
045 : ["Disease", null,null, preload("res://dk_images/keepower_64/disease_std.png"), null, TAB_SPELL],
046 : ["Chicken Spell", null,null, preload("res://dk_images/keepower_64/chicken_std.png"), null, TAB_SPELL],
047 : ["Destroy Walls", null,null, preload("res://dk_images/keepower_64/dstwall_std.png"), null, TAB_SPELL],
048 : ["Time Bomb", null,null, preload("res://edited_images/timebomb.png"), null, TAB_SPELL], 
049 : ["Hero Gate", null,null, preload("res://dk_images/crucials/anim0780/AnimHeroGate.tres"), null, TAB_ACTION],
050 : ["Spinning Key 2", null,null, preload("res://dk_images/traps_doors/anim0811/AnimSpinningKey.tres"), null, TAB_MISC],
051 : ["Armour Effect", null,null, null, null, TAB_MISC],
052 : ["Treasury Hoard 1 (400)", null,null, preload("res://dk_images/valuables/gold_hoard1_tp/AnimGoldHoard1.tres"), null, TAB_GOLD],
053 : ["Treasury Hoard 2 (800)", null,null, preload("res://dk_images/valuables/gold_hoard2_tp/AnimGoldHoard2.tres"), null, TAB_GOLD],
054 : ["Treasury Hoard 3 (1200)", null,null, preload("res://dk_images/valuables/gold_hoard3_tp/AnimGoldHoard3.tres"), null, TAB_GOLD],
055 : ["Treasury Hoard 4 (1600)", null,null, preload("res://dk_images/valuables/gold_hoard4_tp/AnimGoldHoard4.tres"), null, TAB_GOLD],
056 : ["Treasury Hoard 5 (2000)", null,null, preload("res://dk_images/valuables/gold_hoard5_tp/AnimGoldHoard5.tres"), null, TAB_GOLD],
057 : ["Lair: Wizard", null,null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
058 : ["Lair: Barbarian", null,null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
059 : ["Lair: Archer", null,null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
060 : ["Lair: Monk", null,null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
061 : ["Lair: Dwarf", null,null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
062 : ["Lair: Knight", null,null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
063 : ["Lair: Avatar", null,null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
064 : ["Lair: Tunneller", null,null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
065 : ["Lair: Witch", null,null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
066 : ["Lair: Giant", null,null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
067 : ["Lair: Fairy", null,null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
068 : ["Lair: Thief", null,null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
069 : ["Lair: Samurai", null,null, preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"), null, TAB_LAIR],
070 : ["Lair: Horny", null,null, preload("res://edited_images/lair/creature_horny/anim0160/AnimLairHornedReaper.tres"), null, TAB_LAIR],
071 : ["Lair: Skeleton", null,null, preload("res://edited_images/lair/creature_skeleton/anim0158/AnimLairSkeleton.tres"), null, TAB_LAIR],
072 : ["Lair: Troll", null,null, preload("res://edited_images/lair/creature_generic/anim0156/r1frame01.png"), null, TAB_LAIR],
073 : ["Lair: Dragon", null,null, preload("res://edited_images/lair/creature_dragon/anim0154/AnimLairDragon.tres"), null, TAB_LAIR],
074 : ["Lair: Demon Spawn", null,null, preload("res://edited_images/lair/creature_demonspawn/lairempty_tp/r1frame01.png"), null, TAB_LAIR],
075 : ["Lair: Fly", null,null, preload("res://edited_images/lair/creature_fly/anim0150/AnimLairFly.tres"), null, TAB_LAIR],
076 : ["Lair: Mistress", null,null, preload("res://edited_images/lair/creature_dkmistress/anim0148/AnimLairMistress.tres"), null, TAB_LAIR],
077 : ["Lair: Warlock", null,null, preload("res://edited_images/lair/creature_warlock/anim0146/AnimLairWarlock.tres"), null, TAB_LAIR],
078 : ["Lair: Bile Demon", null,null, preload("res://edited_images/lair/creature_biledemon/anim0144/AnimLairBileDemon.tres"), null, TAB_LAIR],
079 : ["Lair: Imp", null,null, preload("res://edited_images/lair/creature_dragon/anim0154/r1frame01.png"), null, TAB_LAIR],
080 : ["Lair: Beetle", null,null, preload("res://edited_images/lair/creature_bug/anim0142/AnimLairBeetle.tres"), null, TAB_LAIR],
081 : ["Lair: Vampire", null,null, preload("res://edited_images/lair/creature_vampire/anim0140/r1frame01.png"), null, TAB_LAIR],
082 : ["Lair: Spider", null,null, preload("res://edited_images/lair/creature_spider/anim0138/AnimLairSpider.tres"), null, TAB_LAIR],
083 : ["Lair: Hell Hound", null,null, preload("res://edited_images/lair/creature_hound/anim0136/r1frame01.png"), null, TAB_LAIR],
084 : ["Lair: Ghost", null,null, preload("res://edited_images/lair/creature_ghost/anim0134/r1frame01.png"), null, TAB_LAIR],
085 : ["Lair: Tentacle", null,null, preload("res://edited_images/lair/creature_tentacle/anim0130/r1frame01.png"), null, TAB_LAIR],
086 : ["Reveal Map", null,null, preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
087 : ["Resurrect Creature", null,null, preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
088 : ["Transfer Creature", null,null, preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
089 : ["Steal Hero", null,null, preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
090 : ["Multiply Creatures", null,null, preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
091 : ["Increase Level", null,null, preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
092 : ["Make Safe", null,null, preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
093 : ["Locate Hidden World", null,null, preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
094 : ["Box: Boulder Trap", null,null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
095 : ["Box: Alarm Trap", null,null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
096 : ["Box: Poison Gas Trap", null,null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
097 : ["Box: Lightning Trap", null,null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
098 : ["Box: Word of Power Trap", null,null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
099 : ["Box: Lava Trap", null,null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
100 : ["Box: Dummy Trap 2", null,null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
101 : ["Box: Dummy Trap 3", null,null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
102 : ["Box: Dummy Trap 4", null,null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
103 : ["Box: Dummy Trap 5", null,null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
104 : ["Box: Dummy Trap 6", null,null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
105 : ["Box: Dummy Trap 7", null,null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
106 : ["Box: Wooden Door", null,null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
107 : ["Box: Braced Door", null,null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
108 : ["Box: Iron Door", null,null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
109 : ["Box: Magic Door", null,null, preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"), null, TAB_BOX],
110 : ["Workshop Item", null,null, preload("res://dk_images/furniture/workshop_anvil_tp/r1frame01.png"), null, TAB_MISC],
111 : ["Red Heart Flame", null,null, preload("res://dk_images/magic_fogs/anim0801/AnimRedHeartFlame.tres"), null, TAB_FURNITURE],
112 : ["Disease Effect", null,null, null, null, TAB_MISC],
113 : ["Scavenger Eye", null,null, preload("res://dk_images/furniture/scavenge_eye_tp/AnimScavengerEye.tres"), null, TAB_FURNITURE],
114 : ["Workshop Machine", null,null, preload("res://dk_images/furniture/workshop_machine_tp/AnimWorkshopMachine.tres"), null, TAB_FURNITURE],
115 : ["Red Flag", null,null, preload("res://dk_images/furniture/flagpole_redflag_tp/AnimFlagpoleRed.tres"), null, TAB_FURNITURE],
116 : ["Blue Flag", null,null, preload("res://dk_images/furniture/flagpole_blueflag_tp/AnimFlagpoleBlue.tres"), null, TAB_FURNITURE],
117 : ["Green Flag", null,null, preload("res://dk_images/furniture/flagpole_greenflag_tp/AnimFlagpoleGreen.tres"), null, TAB_FURNITURE],
118 : ["Yellow Flag", null,null, preload("res://dk_images/furniture/flagpole_yellowflag_tp/AnimFlagpoleYellow.tres"), null, TAB_FURNITURE],
119 : ["Flagpole", null,null, preload("res://dk_images/furniture/flagpole_empty_tp/r1frame01.png"), null, TAB_FURNITURE],
120 : ["Blue Heart Flame", null,null, preload("res://dk_images/magic_fogs/anim0802/AnimBlueHeartFlame.tres"), null, TAB_FURNITURE],
121 : ["Green Heart Flame", null,null, preload("res://dk_images/magic_fogs/anim0800/AnimGreenHeartFlame.tres"), null, TAB_FURNITURE],
122 : ["Yellow Heart Flame", null,null, preload("res://dk_images/magic_fogs/anim0799/AnimYellowHeartFlame.tres"), null, TAB_FURNITURE],
123 : ["Casted Sight", null,null, preload("res://dk_images/magic_fogs/anim0854/AnimCastedSight.tres"), null, TAB_MISC],
124 : ["Casted Lightning", null,null, null, null, TAB_MISC],
125 : ["Torturer", null,null, preload("res://dk_images/furniture/torture_machine_tp/r1frame01.png"), null, TAB_FURNITURE],
126 : ["Lair: Orc", null,null, preload("res://edited_images/lair/creature_orc/anim0128/r1frame01.png"), null, TAB_LAIR],
127 : ["Power Hand Gold", null,null, preload("res://dk_images/power_hand/anim0782/AnimePowerHandGold.tres"), null, TAB_MISC],
128 : ["Spinning Coin", null,null, null, null, TAB_MISC],
129 : ["Unlit Statue", null,null, preload("res://dk_images/statues/anim0954/r1frame01.png"), null, TAB_DECORATION],
130 : ["Statue 3", null,null, preload("res://dk_images/statues/anim0956/r1frame01.png"), null, TAB_DECORATION],
131 : ["Statue 4", null,null, preload("res://dk_images/statues/anim0958/r1frame01.png"), null, TAB_DECORATION],
132 : ["Statue 5", null,null, preload("res://dk_images/statues/anim0960/r1frame01.png"), null, TAB_DECORATION],
133 : ["Mysterious Box", null,null, preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
134 : ["Armageddon", null,null, preload("res://dk_images/keepower_64/armagedn_std.png"), null, TAB_SPELL],
135 : ["Possess", null,null, preload("res://dk_images/keepower_64/possess_std.png"), null, TAB_SPELL],
136 : ["Gold Bag (100)", null,null, preload("res://dk_images/valuables/gold_sack_tp/r1frame01.png"), null, TAB_GOLD],
}

var LIST_OF_BOXES = {
094 : [TYPE.TRAP, 1], # Boulder Trap
095 : [TYPE.TRAP, 2], # Alarm Trap
096 : [TYPE.TRAP, 3], # Poison Gas Trap
097 : [TYPE.TRAP, 4], # Lightning Trap
098 : [TYPE.TRAP, 5], # Word of Power Trap
099 : [TYPE.TRAP, 6], # Lava Trap
100 : [TYPE.TRAP, 7], # Dummy Trap 2
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

var haveFullySetupDefaultData = false



func reset_thing_data_to_default():
	if haveFullySetupDefaultData == false:
		haveFullySetupDefaultData = true
		var oGame = Nodelist.list["oGame"]
		read_all_things_cfg_from_dir(oGame.DK_FXDATA_DIRECTORY, 0)
	
	# Reset data. Takes 1ms.
	DATA_EXTRA = default_data["DATA_EXTRA"].duplicate(true)
	DATA_DOOR = default_data["DATA_DOOR"].duplicate(true)
	DATA_TRAP = default_data["DATA_TRAP"].duplicate(true)
	DATA_EFFECTGEN = default_data["DATA_EFFECTGEN"].duplicate(true)
	DATA_CREATURE = default_data["DATA_CREATURE"].duplicate(true)
	DATA_OBJECT = default_data["DATA_OBJECT"].duplicate(true)


func get_cfgs_directory(fullPathToMainCfg):
	var oGame = Nodelist.list["oGame"]
	
	var massiveString = file_to_upper_string(fullPathToMainCfg.get_base_dir(), fullPathToMainCfg.get_file())
	if massiveString is String:
		var bigListOfLines = massiveString.split('\n',false)
		for line in bigListOfLines:
			var componentsOfLine = line.split('=', false)
			if componentsOfLine.size() >= 2:
				if componentsOfLine[0].strip_edges() == "CONFIGS_LOCATION":
					var configsLocationValue = componentsOfLine[1].strip_edges()
					var fullCfgsDir = oGame.GAME_DIRECTORY.plus_file(configsLocationValue)
					
					read_all_things_cfg_from_dir(fullCfgsDir, 1)
					return

func read_all_things_cfg_from_dir(dir, load_into):
	var CODETIME_START = OS.get_ticks_msec()
	
	for i in 4:
		match i:
			0:
				var massiveString = file_to_upper_string(dir, "OBJECTS.CFG")
				if massiveString is String:
					if load_into == 0:
						cfg_objects(massiveString, default_data["DATA_OBJECT"])
					else:
						cfg_objects(massiveString, DATA_OBJECT)
			1:
				var massiveString = file_to_upper_string(dir, "CREATURE.CFG")
				if massiveString is String:
					if load_into == 0:
						cfg_creatures(massiveString, default_data["DATA_CREATURE"])
					else:
						cfg_creatures(massiveString, DATA_CREATURE)
			2:
				var massiveString = file_to_upper_string(dir, "TRAPDOOR.CFG")
				if massiveString is String:
					if load_into == 0:
						cfg_traps(massiveString, default_data["DATA_TRAP"])
					else:
						cfg_traps(massiveString, DATA_TRAP)
			3:
				var massiveString = file_to_upper_string(dir, "TRAPDOOR.CFG")
				if massiveString is String:
					if load_into == 0:
						cfg_doors(massiveString, default_data["DATA_DOOR"])
					else:
						cfg_doors(massiveString, DATA_DOOR)
	print('All thing cfgs read in: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')


func cfg_objects(massiveString, DATA_ARRAY):
	
	var listSections = massiveString.split('[OBJECT',false)
	if listSections.size() > 0: listSections.remove(0) # get rid of the first section since it just contains stuff before [object0]
	var objectID = 0
	for section in listSections:
		
		var bigListOfLines = section.split('\n',false)
		if bigListOfLines.size() > 0:
			var header = bigListOfLines[0].strip_edges() # First line will always be the header, because that's where it was split at
			objectID = header.to_int() # Set objectID to header
			if DATA_ARRAY.has(objectID) == false:
				DATA_ARRAY[objectID] = [null, null, null, null, null, null] # Initialize empty space for each new entry in .cfg
		
		for line in bigListOfLines:
			var componentsOfLine = line.split('=', false)
			if componentsOfLine.size() >= 2:
				
				if componentsOfLine[0].strip_edges() == "NAME":
					var thingCfgName = componentsOfLine[1].strip_edges()
					var do = false
					if default_data["DATA_OBJECT"].has(objectID) == false:
						do = true
					if DATA_ARRAY[objectID][NAME] == null:
						do = true
#					elif default_data["DATA_OBJECT"][objectID][NAME] == null:
#						do = true
#					elif thingCfgName != default_data["DATA_OBJECT"][objectID][KEEPERFX_NAME] or DATA_ARRAY[objectID][KEEPERFX_NAME] == null:
#						do = true
					
					if do == true:
						DATA_ARRAY[objectID][KEEPERFX_NAME] = thingCfgName # Always set CFG name
						DATA_ARRAY[objectID][NAME] = thingCfgName.capitalize()
						look_for_images_to_load(DATA_ARRAY, objectID, thingCfgName)
					
				elif componentsOfLine[0].strip_edges() == "GENRE" and objectID != 0:
					var thingGenre = componentsOfLine[1].strip_edges()
					var thingTab = GENRE_TO_TAB[thingGenre]
					
					var do = false
					if default_data["DATA_OBJECT"].has(objectID) == false:
						do = true
					elif DATA_ARRAY[objectID][EDITOR_TAB] == null: #thingTab != default_data["DATA_OBJECT"][objectID][EDITOR_TAB] or
						do = true
					
					if do == true:
						DATA_ARRAY[objectID][EDITOR_TAB] = thingTab
					
				elif componentsOfLine[0].strip_edges() == "ANIMATIONID":
					var thingAnimationID = componentsOfLine[1].strip_edges()
					look_for_images_to_load(DATA_ARRAY, objectID, thingAnimationID)
					DATA_ARRAY[objectID][ANIMATION_ID] = thingAnimationID
					
					if DATA_ARRAY[objectID][TEXTURE] == null:
						call_deferred("set_image_based_on_animation_id", TYPE.OBJECT, objectID, thingAnimationID) # Do it next frame after everything has been appended inside animation_id_to_image, so we can look through it all.
					else:
						animation_id_to_image[thingAnimationID] = DATA_ARRAY[objectID][TEXTURE]

func cfg_traps(massiveString, DATA_ARRAY):
	var listSections = massiveString.split('[TRAP',false)
	if listSections.size() > 0: listSections.remove(0) # get rid of the first section since it just contains stuff before [object0]
	var objectID = 0
	for section in listSections:
		
		var bigListOfLines = section.split('\n',false)
		if bigListOfLines.size() > 0:
			var header = bigListOfLines[0].strip_edges() # First line will always be the header, because that's where it was split at
			objectID = header.to_int() # Set objectID to header
			if DATA_ARRAY.has(objectID) == false:
				DATA_ARRAY[objectID] = [null, null, null, null, null, null] # Initialize empty space for each new entry in .cfg
		
		var already_assigned_name = false # This is needed otherwise traps and doors sometimes use each other's fields
		var already_assigned_animation_id = false
		
		for line in bigListOfLines:
			var componentsOfLine = line.split('=', false)
			if componentsOfLine.size() >= 2:
				
				if componentsOfLine[0].strip_edges() == "NAME" and already_assigned_name == false:
					var thingCfgName = componentsOfLine[1].strip_edges()
					DATA_ARRAY[objectID][KEEPERFX_NAME] = thingCfgName # Always set CFG name
					already_assigned_name = true
					if DATA_ARRAY[objectID][NAME] == null or objectID >= 7: # Only change name if it's a newly added item OR a Dummy Trap
						DATA_ARRAY[objectID][NAME] = thingCfgName.capitalize()
					look_for_images_to_load(DATA_ARRAY, objectID, thingCfgName)
				elif componentsOfLine[0].strip_edges() == "ANIMATIONID" and already_assigned_animation_id == false:
					var thingAnimationID = componentsOfLine[1].strip_edges()
					look_for_images_to_load(DATA_ARRAY, objectID, thingAnimationID)
					DATA_ARRAY[objectID][ANIMATION_ID] = thingAnimationID
					already_assigned_animation_id = true
					
					if DATA_ARRAY[objectID][TEXTURE] == null:
						call_deferred("set_image_based_on_animation_id", TYPE.TRAP, objectID, thingAnimationID) # Do it next frame after everything has been appended inside animation_id_to_image, so we can look through it all.
					else:
						animation_id_to_image[thingAnimationID] = DATA_ARRAY[objectID][TEXTURE]


func cfg_doors(massiveString, DATA_ARRAY):
	var listSections = massiveString.split('[DOOR',false)
	if listSections.size() > 0: listSections.remove(0) # get rid of the first section since it just contains stuff before [object0]
	var objectID = 0
	for section in listSections:
		var bigListOfLines = section.split('\n',false)
		if bigListOfLines.size() > 0:
			var header = bigListOfLines[0].strip_edges() # First line will always be the header, because that's where it was split at
			objectID = header.to_int() # Set objectID to header
			if DATA_ARRAY.has(objectID) == false:
				DATA_ARRAY[objectID] = [null, null, null, null, null, null] # Initialize empty space for each new entry in .cfg
		
		var already_assigned_name = false # This is needed otherwise traps and doors sometimes use each other's fields
		var already_assigned_animation_id = false
		
		for line in bigListOfLines:
			
			var componentsOfLine = line.split('=', false)
			if componentsOfLine.size() >= 2:
				
				if componentsOfLine[0].strip_edges() == "NAME" and already_assigned_name == false:
					var thingCfgName = componentsOfLine[1].strip_edges()
					DATA_ARRAY[objectID][KEEPERFX_NAME] = thingCfgName
					already_assigned_name = true
					if DATA_ARRAY[objectID][NAME] == null: # Only set editor name if it's a newly added item
						DATA_ARRAY[objectID][NAME] = thingCfgName.capitalize()
					look_for_images_to_load(DATA_ARRAY, objectID, thingCfgName)
				elif componentsOfLine[0].strip_edges() == "ANIMATIONID" and already_assigned_animation_id == false:
					var thingAnimationID = componentsOfLine[1].strip_edges()
					look_for_images_to_load(DATA_ARRAY, objectID, thingAnimationID)
					DATA_ARRAY[objectID][ANIMATION_ID] = thingAnimationID
					already_assigned_animation_id = true
					
					if DATA_ARRAY[objectID][TEXTURE] == null:
						call_deferred("set_image_based_on_animation_id", TYPE.DOOR, objectID, thingAnimationID) # Do it next frame after everything has been appended inside animation_id_to_image, so we can look through it all.
					else:
						animation_id_to_image[thingAnimationID] = DATA_ARRAY[objectID][TEXTURE]

func cfg_creatures(massiveString, DATA_ARRAY):
	var bigListOfLines = massiveString.split('\n',false)
	for line in bigListOfLines:
		var componentsOfLine = line.split('=', false)
		if componentsOfLine.size() >= 2:
			if componentsOfLine[0].strip_edges() == "CREATURES":
				var creaturesList = componentsOfLine[1].strip_edges().split(' ', false)
				var objectID = 0
				creaturesList.insert(0, "")
				while true:
					if objectID > 0: # Ignore null
						if DATA_ARRAY.has(objectID) == false:
							DATA_ARRAY[objectID] = [null, null, null, null, null, null] # Initialize empty space for each new entry in .cfg
						
						var thingCfgName = creaturesList[objectID].strip_edges()
						#if DATA_ARRAY[objectID][KEEPERFX_NAME] == null:
						DATA_ARRAY[objectID][KEEPERFX_NAME] = thingCfgName
						DATA_ARRAY[objectID][NAME] = get_proper_creature_name(thingCfgName.capitalize())
						DATA_ARRAY[objectID][EDITOR_TAB] = TAB_CREATURE
						look_for_images_to_load(DATA_ARRAY, objectID, thingCfgName)
					
					objectID += 1
					if objectID >= creaturesList.size():
						return
				
				return # exit early

func get_proper_creature_name(nm):
	match nm:
		"Horny": return "Horned Reaper"
		"Dwarfa": return "Dwarf"
		"Demonspawn": return "Demon Spawn"
		"Sorcerer": return "Warlock"
		"Bug": return "Beetle"
	return nm

func set_image_based_on_animation_id(thingType, objectID, thingAnimationID):
	if int(thingAnimationID) == 0:
		return # This is important, if ANIMATIONID is 0 then it shouldn't be set. It should be a grey diamond.
	
	if animation_id_to_image.has(thingAnimationID):
		match thingType:
			Things.TYPE.OBJECT: DATA_OBJECT[objectID][TEXTURE] = animation_id_to_image[thingAnimationID]
			Things.TYPE.CREATURE: DATA_CREATURE[objectID][TEXTURE] = animation_id_to_image[thingAnimationID]
			Things.TYPE.EFFECTGEN: DATA_EFFECTGEN[objectID][TEXTURE] = animation_id_to_image[thingAnimationID]
			Things.TYPE.TRAP: DATA_TRAP[objectID][TEXTURE] = animation_id_to_image[thingAnimationID]
			Things.TYPE.DOOR: DATA_DOOR[objectID][TEXTURE] = animation_id_to_image[thingAnimationID]
			Things.TYPE.EXTRA: DATA_EXTRA[objectID][TEXTURE] = animation_id_to_image[thingAnimationID]

func file_to_upper_string(dir, fileName):
	var oGame = Nodelist.list["oGame"]
	var path = oGame.get_precise_filepath(dir, fileName)
	
	var file = File.new()
	if path == "" or file.open(path, File.READ) != OK:
		return -1
	var massiveString = file.get_as_text().to_upper() # Make it easier to read by making it all upper case
	file.close()
	return massiveString


func get_zip_files_in_dir(path):
	var array = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
			else:
				if file_name.get_extension().to_upper() == "ZIP":
					array.append(path.plus_file(file_name))
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return array

func look_for_images_to_load(DATA_ARRAY, objectID, thingCfgName):
	if custom_images_list.empty() == true:
		custom_images_list = get_png_filenames_in_dir(Settings.unearthdata.plus_file("custom-object-images"))
	
	var dir = Settings.unearthdata.plus_file("custom-object-images")
	
	var uppercaseImageFilename = thingCfgName+".PNG".to_upper()
	var uppercasePortraitFilename = thingCfgName+"_PORTRAIT.PNG".to_upper()
	
	var realImageFilename = ""
	var realPortraitFilename = ""
	
	if custom_images_list.has(uppercaseImageFilename):
		 realImageFilename = custom_images_list[uppercaseImageFilename]
	
	if custom_images_list.has(uppercasePortraitFilename):
		 realPortraitFilename = custom_images_list[uppercasePortraitFilename]
	
	if realImageFilename != "":
		var img = Image.new()
		var err = img.load(dir.plus_file(realImageFilename))
		if err == OK:
			var tex = ImageTexture.new()
			tex.create_from_image(img, Texture.FLAG_MIPMAPS+Texture.FLAG_ANISOTROPIC_FILTER)
			DATA_ARRAY[objectID][TEXTURE] = tex
	
	if realPortraitFilename != "":
		var img = Image.new()
		var err = img.load(dir.plus_file(realPortraitFilename))
		if err == OK:
			var tex = ImageTexture.new()
			tex.create_from_image(img, Texture.FLAG_MIPMAPS+Texture.FLAG_ANISOTROPIC_FILTER)
			DATA_ARRAY[objectID][PORTRAIT] = tex



func get_png_filenames_in_dir(path):
	var dictionary = {}
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
			else:
				if file_name.get_extension().to_upper() == "PNG":
					dictionary[file_name.to_upper().replace(" ", "_")] = file_name
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return dictionary

func convert_relative_256_to_float(datnum):
	if datnum >= 32768: # If the sign bit is set (indicating a negative value)
		datnum -= 65536 # Convert to signed by subtracting 2^16
	return datnum / 256.0 # Scale it to floating-point

#func load_custom_images_into_array(DATA_ARRAY, thingtypeImageFolder):
#	print("Loading /thing-images/" + thingtypeImageFolder + " directory ...")
#	var arrayOfFilenames = get_png_files_in_dir(Settings.unearthdata.plus_file("thing-images").plus_file(thingtypeImageFolder))
#	for i in arrayOfFilenames:
#		var subtypeID = int(i.get_file().get_basename())
#		var img = Image.new()
#		var err = img.load(i)
#		if err == OK:
#			var tex = ImageTexture.new()
#			tex.create_from_image(img)
#			if DATA_ARRAY.has(subtypeID):
#				DATA_ARRAY[subtypeID][TEXTURE] = tex


#func get_png_files_in_dir(path):
#	var array = []
#	var dir = Directory.new()
#	if dir.open(path) == OK:
#		dir.list_dir_begin()
#		var file_name = dir.get_next()
#		while file_name != "":
#			if dir.current_is_dir():
#				pass
#			else:
#				if file_name.get_extension().to_upper() == "PNG":
#					var fileNumber = file_name.get_file().get_basename()
#					if Utils.string_has_letters(fileNumber) == false:
#						array.append(path.plus_file(file_name))
#			file_name = dir.get_next()
#	else:
#		print("An error occurred when trying to access the path.")
#	return array


#
#static func thing_text(array):
#	var typeArgument = array[THING_TYPE]
#	var subtypeArgument = array[THING_SUBTYPE]
#
#	match typeArgument:
#		TYPE.NONE: return ''
#		TYPE.ITEM: return DATA_OBJECT[subtypeArgument][NAME]
#		TYPE.CREATURE: return DATA_CREATURE[subtypeArgument][NAME]
#		TYPE.EFFECT: return DATA_EFFECTGEN[subtypeArgument][NAME]
#		TYPE.TRAP: return DATA_TRAP[subtypeArgument][NAME]
#		TYPE.DOOR: return DATA_DOOR[subtypeArgument][NAME]
#	return 'UNKNOWN'
#
#static func thing_portrait(array):
#	var typeArgument = array[THING_TYPE]
#	var subtypeArgument = array[THING_SUBTYPE]
#
#	var tmp = null
#	# If the portait field in the array is null, use the texture.
#	match typeArgument:
#		TYPE.NONE:
#			return null
#		TYPE.ITEM:
#			tmp = DATA_OBJECT[subtypeArgument][PORTRAIT]
#			if tmp == null: tmp = DATA_OBJECT[subtypeArgument][TEXTURE]
#		TYPE.CREATURE:
#			tmp = DATA_CREATURE[subtypeArgument][PORTRAIT]
#			if tmp == null: tmp = DATA_CREATURE[subtypeArgument][TEXTURE]
#		TYPE.EFFECT:
#			tmp = DATA_EFFECTGEN[subtypeArgument][PORTRAIT]
#			if tmp == null: tmp = DATA_EFFECTGEN[subtypeArgument][TEXTURE]
#		TYPE.TRAP:
#			tmp = DATA_TRAP[subtypeArgument][PORTRAIT]
#			if tmp == null: tmp = DATA_TRAP[subtypeArgument][TEXTURE]
#		TYPE.DOOR:
#			tmp = DATA_DOOR[subtypeArgument][PORTRAIT]
#			if tmp == null: tmp = DATA_DOOR[subtypeArgument][TEXTURE]
#	return tmp
#
#static func create(array, thingScn):
#	var id = thingScn.instance()
#	id.data = array
#	id.setPosition()
#	id.setOwnership()
#	return id
#
#func get_ownership():
#	return self.data[OWNERSHIP]
#func get_type():
#	return self.data[THING_TYPE]
#func get_subtype():
#	return self.data[THING_SUBTYPE]


#########################################################################
#########################################################################
#########################################################################
#########################################################################
#########################################################################
#########################################################################
#########################################################################
#########################################################################

#	match id.data[THING_TYPE]:
#		TYPE.CREATURE:
#			id.data[CREATURE_LEVEL] = array[CREATURE_LEVEL]
#		TYPE.EFFECT:
#			id.data[THING_RANGE] = array[THING_RANGE]
#			id.data[THING_RANGE_WITHIN] = array[THING_RANGE_WITHIN]

#static func read_thing(node):
##	var SUBTILE_SIZE = 32
##	var TILE_SIZE = 96
#
#	if node == null: return null
#
#	var array = [0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0]
#	# 6: Thing type
#
#	var wholeX = floor(node.position.x / SUBTILE_SIZE)
#	var wholeY = floor(node.position.y / SUBTILE_SIZE)
#	var wholeZ = floor(node.altitude / SUBTILE_SIZE)
#	var decimalX = (node.position.x / SUBTILE_SIZE) - wholeX
#	var decimalY = (node.position.y / SUBTILE_SIZE) - wholeY
#	var decimalZ = (node.altitude / SUBTILE_SIZE) - wholeZ
#
#	array[0] = (decimalX * 256)
#	array[1] = wholeX
#	array[2] = (decimalY * 256)
#	array[3] = wholeY
#	array[4] = (decimalZ * 256)
#	array[5] = wholeZ
#	array[6] = node.data[THING_TYPE]
#	array[7] = node.data[THING_SUBTYPE]
#	array[8] = node.data[OWNERSHIP]
#
#	match node.get_type():
#		TYPE.NONE:
#			pass
#		TYPE.ITEM:
#			# Item/decoration
#			#array[11] = node.parentTile
#			#array[12] = node.parentTile
#			pass
#		TYPE.CREATURE:
#			array[14] = node.data[CREATURE_LEVEL]
#		TYPE.EFFECT:
#			array[9] = node.data[THING_RANGE_WITHIN]
#			array[10] = node.data[THING_RANGE]
#			pass
#		TYPE.TRAP:
#			pass
#		TYPE.DOOR:
#			# Door
#			#array[13] = node.doorOrientation
#			#array[14] = node.doorLocked
#			pass
#
#	return array

#enum {
#	SUBTILE_X_WITHIN = 0
#	SUBTILE_X = 1
#	SUBTILE_Y_WITHIN = 2
#	SUBTILE_Y = 3
#	SUBTILE_Z_WITHIN = 4
#	SUBTILE_Z = 5
#	THING_TYPE = 6
#	THING_SUBTYPE = 7
#	OWNERSHIP = 8
#
#	# Depends on type:
#	THING_RANGE_WITHIN = 9
#	THING_RANGE = 10
#	PARENT_TILE1 = 11
#	PARENT_TILE2 = 12
#	DOOR_ORIENTATION = 13
#	CREATURE_LEVEL = 14
#	DOOR_LOCKED = 14
#	HEROGATE_NUMBER = 14
#}
