extends Node2D

const THING_LIMIT = 2048
const ACTION_POINT_LIMIT = 255
const CREATURE_LIMIT = 255
const LIGHT_LIMIT = -1

enum TYPE {
	NONE = 0
	OBJECT = 1
	CREATURE = 5
	EFFECT = 7
	TRAP = 8
	DOOR = 9
	EXTRA = 696969
}
enum {
	NAME = 0
	KEEPERFX_ID = 1
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
	TAB_EFFECT
	TAB_FURNITURE
	TAB_DECORATION
	TAB_MISC
}

var GENRE_TO_TAB = {
	"DECORATION": TAB_DECORATION,
	"EFFECT": TAB_EFFECT,
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
1 : ["Action Point", "TEMP", preload("res://Art/ActionPoint.png"), null, TAB_ACTION],
2 : ["Light", "TEMP", preload("res://edited_images/GUIEDIT-1/PIC26.png"), null, TAB_EFFECT],
}

var DATA_DOOR = {
1 : ["Wooden Door", "TEMP", preload("res://dk_images/trapdoor_64/door_pers_wood_std.png"), null, TAB_MISC],
2 : ["Braced Door", "TEMP", preload("res://dk_images/trapdoor_64/door_pers_braced_std.png"), null, TAB_MISC],
3 : ["Iron Door", "TEMP", preload("res://dk_images/trapdoor_64/door_pers_iron_std.png"), null, TAB_MISC],
4 : ["Magic Door", "TEMP", preload("res://dk_images/trapdoor_64/door_pers_magic_std.png"), null, TAB_MISC]
}
var DATA_TRAP = {
1 : ["Boulder Trap", "TEMP", preload("res://dk_images/trapdoor_64/trap_boulder_std.png"), null, TAB_TRAP],
2 : ["Alarm Trap", "TEMP", preload("res://dk_images/trapdoor_64/trap_alarm_std.png"), null, TAB_TRAP],
3 : ["Poison Gas Trap", "TEMP", preload("res://dk_images/trapdoor_64/trap_gas_std.png"), null, TAB_TRAP],
4 : ["Lightning Trap", "TEMP", preload("res://dk_images/trapdoor_64/trap_lightning_std.png"), null, TAB_TRAP],
5 : ["Word of Power Trap", "TEMP", preload("res://dk_images/trapdoor_64/trap_wop_std.png"), null, TAB_TRAP],
6 : ["Lava Trap", "TEMP", preload("res://dk_images/trapdoor_64/trap_lava_std.png"), null, TAB_TRAP],
7 : ["Dummy Trap 2", "TEMP", null, null, TAB_TRAP],
8 : ["Dummy Trap 3", "TEMP", null, null, TAB_TRAP],
9 : ["Dummy Trap 4", "TEMP", null, null, TAB_TRAP],
10 : ["Dummy Trap 5", "TEMP", null, null, TAB_TRAP],
11 : ["Dummy Trap 6", "TEMP", null, null, TAB_TRAP],
12 : ["Dummy Trap 7", "TEMP", null, null, TAB_TRAP],
}
var DATA_EFFECT = {
1 : ["Effect: Lava", "EMITTER_LAVA", preload("res://edited_images/GUIEDIT-1/PIC27.png"), null, TAB_EFFECT],
2 : ["Effect: Dripping Water", "EMITTER_DRIPPING_WATER", preload("res://edited_images/GUIEDIT-1/PIC28.png"), null, TAB_EFFECT],
3 : ["Effect: Rock Fall", "EMITTER_ROCK_FALL", preload("res://edited_images/GUIEDIT-1/PIC29.png"), null, TAB_EFFECT],
4 : ["Effect: Entrance Ice", "EMITTER_ENTRANCE_ICE", preload("res://edited_images/GUIEDIT-1/PIC30.png"), null, TAB_EFFECT],
5 : ["Effect: Dry Ice", "EMITTER_DRY_ICE", preload("res://edited_images/GUIEDIT-1/PIC31.png"), null, TAB_EFFECT]
}
var DATA_CREATURE = {
01 : ["Wizard", "TEMP",          preload("res://edited_images/creatr_icon_64/wizrd_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_wizrd.png"), TAB_CREATURE],
02 : ["Barbarian", "TEMP",       preload("res://edited_images/creatr_icon_64/barbr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_barbr.png"), TAB_CREATURE],
03 : ["Archer", "TEMP",          preload("res://edited_images/creatr_icon_64/archr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_archr.png"), TAB_CREATURE],
04 : ["Monk", "TEMP",            preload("res://edited_images/creatr_icon_64/monk_std.png"),  preload("res://dk_images/creature_portrait_64/creatr_portrt_monk.png"), TAB_CREATURE],
05 : ["Dwarf", "TEMP",           preload("res://edited_images/creatr_icon_64/dwarf_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_dwrf1.png"), TAB_CREATURE],
06 : ["Knight", "TEMP",          preload("res://edited_images/creatr_icon_64/knght_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_knigh.png"), TAB_CREATURE],
07 : ["Avatar", "TEMP",          preload("res://edited_images/creatr_icon_64/avatr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_avatr.png"), TAB_CREATURE],
08 : ["Tunneller", "TEMP",       preload("res://edited_images/creatr_icon_64/tunlr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_dwrf2.png"), TAB_CREATURE],
09 : ["Witch", "TEMP",           preload("res://edited_images/creatr_icon_64/prsts_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_witch.png"), TAB_CREATURE],
10 : ["Giant", "TEMP",           preload("res://edited_images/creatr_icon_64/giant_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_giant.png"), TAB_CREATURE],
11 : ["Fairy", "TEMP",           preload("res://edited_images/creatr_icon_64/fairy_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_fairy.png"), TAB_CREATURE],
12 : ["Thief", "TEMP",           preload("res://edited_images/creatr_icon_64/thief_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_thief.png"), TAB_CREATURE],
13 : ["Samurai", "TEMP",         preload("res://edited_images/creatr_icon_64/samur_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_samur.png"), TAB_CREATURE],
14 : ["Horned Reaper", "TEMP",   preload("res://edited_images/creatr_icon_64/hornd_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_horny.png"), TAB_CREATURE],
15 : ["Skeleton", "TEMP",        preload("res://edited_images/creatr_icon_64/skelt_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_skelt.png"), TAB_CREATURE],
16 : ["Troll", "TEMP",           preload("res://edited_images/creatr_icon_64/troll_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_troll.png"), TAB_CREATURE],
17 : ["Dragon", "TEMP",          preload("res://edited_images/creatr_icon_64/dragn_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_dragn.png"), TAB_CREATURE],
18 : ["Demon Spawn", "TEMP",     preload("res://edited_images/creatr_icon_64/dspwn_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_spawn.png"), TAB_CREATURE],
19 : ["Fly", "TEMP",             preload("res://edited_images/creatr_icon_64/fly_std.png"),   preload("res://dk_images/creature_portrait_64/creatr_portrt_fly.png"), TAB_CREATURE],
20 : ["Dark Mistress", "TEMP",   preload("res://edited_images/creatr_icon_64/dkmis_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_mistr.png"), TAB_CREATURE],
21 : ["Warlock", "TEMP",         preload("res://edited_images/creatr_icon_64/warlk_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_warlk.png"), TAB_CREATURE],
22 : ["Bile Demon", "TEMP",      preload("res://edited_images/creatr_icon_64/biled_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_biled.png"), TAB_CREATURE],
23 : ["Imp", "TEMP",             preload("res://edited_images/creatr_icon_64/imp_std.png"),   preload("res://dk_images/creature_portrait_64/creatr_portrt_imp.png"), TAB_CREATURE],
24 : ["Beetle", "TEMP",          preload("res://edited_images/creatr_icon_64/bug_std.png"),   preload("res://dk_images/creature_portrait_64/creatr_portrt_bug.png"), TAB_CREATURE],
25 : ["Vampire", "TEMP",         preload("res://edited_images/creatr_icon_64/vampr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_vampr.png"), TAB_CREATURE],
26 : ["Spider", "TEMP",          preload("res://edited_images/creatr_icon_64/spidr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_spidr.png"), TAB_CREATURE],
27 : ["Hell Hound", "TEMP",      preload("res://edited_images/creatr_icon_64/hound_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_hound.png"), TAB_CREATURE],
28 : ["Ghost", "TEMP",           preload("res://edited_images/creatr_icon_64/ghost_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_ghost.png"), TAB_CREATURE],
29 : ["Tentacle", "TEMP",        preload("res://edited_images/creatr_icon_64/tentc_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_tentc.png"), TAB_CREATURE],
30 : ["Orc", "TEMP",             preload("res://edited_images/creatr_icon_64/orc_std.png"),   preload("res://dk_images/creature_portrait_64/creatr_portrt_orc.png"), TAB_CREATURE],
31 : ["Floating Spirit", "TEMP", preload("res://dk_images/magic_dust/anim0981/r1frame02.png"), preload("res://dk_images/magic_dust/anim0981/r1frame02.png"), TAB_CREATURE] # wrong icon probably
}

var DATA_OBJECT = {
001 : ["Barrel", "TEMP", preload("res://dk_images/other/anim0932/r1frame01.png"), null, TAB_DECORATION],
002 : ["Torch", "TEMP", preload("res://dk_images/other/anim0963/r1frame01.png"), null, TAB_DECORATION], #TAB_FURNITURE
003 : ["Gold Pot (500)", "TEMP", preload("res://dk_images/valuables/gold_pot_tp/AnimGoldPot.res"), null, TAB_GOLD],
004 : ["Lit Statue", "TEMP", preload("res://dk_images/statues/anim0952/AnimLitStatue.res"), null, TAB_DECORATION], #TAB_FURNITURE
005 : ["Dungeon Heart", "TEMP", preload("res://dk_images/crucials/anim0950/AnimDungeonHeart.res"), null, TAB_FURNITURE],
006 : ["Gold Pot (250)", "TEMP", preload("res://dk_images/valuables/gold_pot_tp/AnimGoldPot.res"), null, TAB_GOLD],
007 : ["Unlit Torch", "TEMP", preload("res://dk_images/other/anim0963/r1frame01.png"), null, TAB_DECORATION], #TAB_FURNITURE
008 : ["Glowing Statue", "TEMP", preload("res://dk_images/statues/anim0952/AnimLitStatue.res"), null, TAB_DECORATION], #Lit Statue No Flame # Partially Lit Statue
009 : ["Egg Growing (1)", "TEMP", preload("res://dk_images/food/anim0898/AnimEggGrowing1.res"), null, TAB_MISC],
010 : ["Chicken", "TEMP", preload("res://dk_images/food/anim0822/AnimChicken.res"), null, TAB_MISC],
011 : ["Hand Of Evil", "TEMP", preload("res://edited_images/icon_handofevil.png"), null, TAB_SPELL],
012 : ["Create Imp", "TEMP", preload("res://dk_images/keepower_64/imp_std.png"), null, TAB_SPELL],
013 : ["Must Obey", "TEMP", preload("res://edited_images/mustobey.png"), null, TAB_SPELL],
014 : ["Slap", "TEMP", preload("res://edited_images/icon_slap.png"), null, TAB_SPELL],
015 : ["Sight of Evil", "TEMP", preload("res://dk_images/keepower_64/sight_std.png"), null, TAB_SPELL],
016 : ["Call To Arms", "TEMP", preload("res://dk_images/keepower_64/cta_std.png"), null, TAB_SPELL],
017 : ["Cave-In", "TEMP", preload("res://dk_images/keepower_64/cavein_std.png"), null, TAB_SPELL],
018 : ["Heal", "TEMP", preload("res://dk_images/keepower_64/heal_std.png"), null, TAB_SPELL],
019 : ["Hold Audience", "TEMP", preload("res://dk_images/keepower_64/holdaud_std.png"), null, TAB_SPELL],
020 : ["Lightning Strike", "TEMP", preload("res://dk_images/keepower_64/lightng_std.png"), null, TAB_SPELL],
021 : ["Speed Monster", "TEMP", preload("res://dk_images/keepower_64/speed_std.png"), null, TAB_SPELL],
022 : ["Protect Monster", "TEMP", preload("res://dk_images/keepower_64/armor_std.png"), null, TAB_SPELL],
023 : ["Conceal Monster", "TEMP", preload("res://dk_images/keepower_64/conceal_std.png"), null, TAB_SPELL],
024 : ["Cta Ensign", "TEMP", null, null, TAB_MISC],
025 : ["Room Flag", "TEMP", null, null, TAB_MISC], #TAB_DECORATION
026 : ["Anvil", "TEMP", preload("res://dk_images/furniture/workshop_anvil_tp/r1frame01.png"), null, TAB_FURNITURE],
027 : ["Prison Bar", "TEMP", preload("res://dk_images/other/anim0797/r1frame01.png"), null, TAB_FURNITURE],
028 : ["Candlestick", "TEMP", preload("res://dk_images/furniture/anim0791/r1frame01.png"), null, TAB_DECORATION], #TAB_FURNITURE
029 : ["Gravestone", "TEMP", preload("res://dk_images/furniture/tombstone_tp/r1frame01.png"), null, TAB_FURNITURE],
030 : ["Aztec Statue", "TEMP", preload("res://dk_images/statues/anim0907/r1frame01.png"), null, TAB_DECORATION], #TAB_FURNITURE
031 : ["Training Post", "TEMP", preload("res://dk_images/furniture/training_machine_tp/AnimTrainingMachine.res"), null, TAB_FURNITURE],
032 : ["Torture Spike", "TEMP", preload("res://dk_images/furniture/anim0892/AnimSpike.res"), null, TAB_FURNITURE],
033 : ["Temple Spangle", "TEMP", preload("res://dk_images/magic_fogs/anim0798/AnimTempleSpangle.res"), null, TAB_DECORATION],
034 : ["Purple Potion", "TEMP", preload("res://dk_images/potions/anim0804/r1frame01.png"), null, TAB_DECORATION],
035 : ["Blue Potion", "TEMP", preload("res://dk_images/potions/anim0806/r1frame01.png"), null, TAB_DECORATION],
036 : ["Green Potion", "TEMP", preload("res://dk_images/potions/anim0808/r1frame01.png"), null, TAB_DECORATION],
037 : ["Power Hand", "TEMP", preload("res://dk_images/power_hand/anim0783/AnimePowerHand.res"), null, TAB_MISC],
038 : ["Power Hand Grab", "TEMP", preload("res://dk_images/power_hand/anim0784/AnimePowerHandGrab.res"), null, TAB_MISC],
039 : ["Power Hand Whip", "TEMP", preload("res://dk_images/power_hand/anim0786/AnimePowerHandWhip.res"), null, TAB_MISC],
040 : ["Egg Stable (2)", "TEMP", preload("res://dk_images/food/anim0899/r1frame01.png"), null, TAB_MISC],
041 : ["Egg Wobbling (3)", "TEMP", preload("res://dk_images/food/anim0900/AnimEggWobbling3.res"), null, TAB_MISC],
042 : ["Egg Cracking (4)", "TEMP", preload("res://dk_images/food/anim0901/AnimEggCracking4.res"), null, TAB_MISC],
043 : ["Gold Pile (200)", "TEMP", preload("res://dk_images/valuables/gold_hoard1_tp/AnimGoldHoard1.res"), null, TAB_GOLD],
044 : ["Spinning Key", "TEMP", preload("res://dk_images/traps_doors/anim0811/AnimSpinningKey.res"), null, TAB_MISC],
045 : ["Disease", "TEMP", preload("res://dk_images/keepower_64/disease_std.png"), null, TAB_SPELL],
046 : ["Chicken Spell", "TEMP", preload("res://dk_images/keepower_64/chicken_std.png"), null, TAB_SPELL],
047 : ["Destroy Walls", "TEMP", preload("res://dk_images/keepower_64/dstwall_std.png"), null, TAB_SPELL],
048 : ["Time Bomb", "TEMP", preload("res://edited_images/timebomb.png"), null, TAB_SPELL], 
049 : ["Hero Gate", "TEMP", preload("res://dk_images/crucials/anim0780/AnimHeroGate.res"), null, TAB_ACTION],
050 : ["Spinning Key 2", "TEMP", preload("res://dk_images/traps_doors/anim0811/AnimSpinningKey.res"), null, TAB_MISC],
051 : ["Armour Effect", "TEMP", null, null, TAB_MISC],
052 : ["Treasury Gold 1 (800)", "TEMP", preload("res://dk_images/valuables/gold_hoard1_tp/AnimGoldHoard1.res"), null, TAB_GOLD],
053 : ["Treasury Gold 2 (1200)", "TEMP", preload("res://dk_images/valuables/gold_hoard2_tp/AnimGoldHoard2.res"), null, TAB_GOLD],
054 : ["Treasury Gold 3 (1600)", "TEMP", preload("res://dk_images/valuables/gold_hoard3_tp/AnimGoldHoard3.res"), null, TAB_GOLD],
055 : ["Treasury Gold 4 (2000)", "TEMP", preload("res://dk_images/valuables/gold_hoard4_tp/AnimGoldHoard4.res"), null, TAB_GOLD],
056 : ["Treasury Gold 5 (2400)", "TEMP", preload("res://dk_images/valuables/gold_hoard5_tp/AnimGoldHoard5.res"), null, TAB_GOLD],
057 : ["Lair: Wizard", "TEMP", preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.res"), null, TAB_LAIR],
058 : ["Lair: Barbarian", "TEMP", preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.res"), null, TAB_LAIR],
059 : ["Lair: Archer", "TEMP", preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.res"), null, TAB_LAIR],
060 : ["Lair: Monk", "TEMP", preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.res"), null, TAB_LAIR],
061 : ["Lair: Dwarf", "TEMP", preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.res"), null, TAB_LAIR],
062 : ["Lair: Knight", "TEMP", preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.res"), null, TAB_LAIR],
063 : ["Lair: Avatar", "TEMP", preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.res"), null, TAB_LAIR],
064 : ["Lair: Tunneller", "TEMP", preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.res"), null, TAB_LAIR],
065 : ["Lair: Witch", "TEMP", preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.res"), null, TAB_LAIR],
066 : ["Lair: Giant", "TEMP", preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.res"), null, TAB_LAIR],
067 : ["Lair: Fairy", "TEMP", preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.res"), null, TAB_LAIR],
068 : ["Lair: Thief", "TEMP", preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.res"), null, TAB_LAIR],
069 : ["Lair: Samurai", "TEMP", preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.res"), null, TAB_LAIR],
070 : ["Lair: Horny", "TEMP", preload("res://edited_images/lair/creature_horny/anim0160/AnimLairHornedReaper.res"), null, TAB_LAIR],
071 : ["Lair: Skeleton", "TEMP", preload("res://edited_images/lair/creature_skeleton/anim0158/AnimLairSkeleton.res"), null, TAB_LAIR],
072 : ["Lair: Troll", "TEMP", preload("res://edited_images/lair/creature_generic/anim0156/r1frame01.png"), null, TAB_LAIR],
073 : ["Lair: Dragon", "TEMP", preload("res://edited_images/lair/creature_dragon/anim0154/AnimLairDragon.res"), null, TAB_LAIR],
074 : ["Lair: Demon Spawn", "TEMP", preload("res://edited_images/lair/creature_demonspawn/lairempty_tp/r1frame01.png"), null, TAB_LAIR],
075 : ["Lair: Fly", "TEMP", preload("res://edited_images/lair/creature_fly/anim0150/AnimLairFly.res"), null, TAB_LAIR],
076 : ["Lair: Mistress", "TEMP", preload("res://edited_images/lair/creature_dkmistress/anim0148/AnimLairMistress.res"), null, TAB_LAIR],
077 : ["Lair: Warlock", "TEMP", preload("res://edited_images/lair/creature_warlock/anim0146/AnimLairWarlock.res"), null, TAB_LAIR],
078 : ["Lair: Bile Demon", "TEMP", preload("res://edited_images/lair/creature_biledemon/anim0144/AnimLairBileDemon.res"), null, TAB_LAIR],
079 : ["Lair: Imp", "TEMP", preload("res://edited_images/lair/creature_dragon/anim0154/r1frame01.png"), null, TAB_LAIR],
080 : ["Lair: Beetle", "TEMP", preload("res://edited_images/lair/creature_bug/anim0142/AnimLairBeetle.res"), null, TAB_LAIR],
081 : ["Lair: Vampire", "TEMP", preload("res://edited_images/lair/creature_vampire/anim0140/r1frame01.png"), null, TAB_LAIR],
082 : ["Lair: Spider", "TEMP", preload("res://edited_images/lair/creature_spider/anim0138/AnimLairSpider.res"), null, TAB_LAIR],
083 : ["Lair: Hell Hound", "TEMP", preload("res://edited_images/lair/creature_hound/anim0136/r1frame01.png"), null, TAB_LAIR],
084 : ["Lair: Ghost", "TEMP", preload("res://edited_images/lair/creature_ghost/anim0134/r1frame01.png"), null, TAB_LAIR],
085 : ["Lair: Tentacle", "TEMP", preload("res://edited_images/lair/creature_tentacle/anim0130/r1frame01.png"), null, TAB_LAIR],
086 : ["Reveal Map", "TEMP", preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
087 : ["Resurrect Creature", "TEMP", preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
088 : ["Transfer Creature", "TEMP", preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
089 : ["Steal Hero", "TEMP", preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
090 : ["Multiply Creatures", "TEMP", preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
091 : ["Increase Level", "TEMP", preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
092 : ["Make Safe", "TEMP", preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
093 : ["Locate Hidden World", "TEMP", preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
094 : ["Box: Boulder Trap", "TEMP", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
095 : ["Box: Alarm Trap", "TEMP", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
096 : ["Box: Poison Gas Trap", "TEMP", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
097 : ["Box: Lightning Trap", "TEMP", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
098 : ["Box: Word of Power Trap", "TEMP", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
099 : ["Box: Lava Trap", "TEMP", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
100 : ["Box: Dummy Trap 2", "TEMP", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
101 : ["Box: Dummy Trap 3", "TEMP", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
102 : ["Box: Dummy Trap 4", "TEMP", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
103 : ["Box: Dummy Trap 5", "TEMP", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
104 : ["Box: Dummy Trap 6", "TEMP", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
105 : ["Box: Dummy Trap 7", "TEMP", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
106 : ["Box: Wooden Door", "TEMP", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
107 : ["Box: Braced Door", "TEMP", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
108 : ["Box: Iron Door", "TEMP", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
109 : ["Box: Magic Door", "TEMP", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
110 : ["Workshop Item", "TEMP", preload("res://dk_images/furniture/workshop_anvil_tp/r1frame01.png"), null, TAB_MISC],
111 : ["Red Heart Flame", "TEMP", preload("res://dk_images/magic_fogs/anim0801/AnimRedHeartFlame.res"), null, TAB_FURNITURE],
112 : ["Disease Effect", "TEMP", null, null, TAB_MISC],
113 : ["Scavenger Eye", "TEMP", preload("res://dk_images/furniture/scavenge_eye_tp/AnimScavengerEye.res"), null, TAB_FURNITURE],
114 : ["Workshop Machine", "TEMP", preload("res://dk_images/furniture/workshop_machine_tp/AnimWorkshopMachine.res"), null, TAB_FURNITURE],
115 : ["Red Flag", "TEMP", preload("res://dk_images/furniture/flagpole_redflag_tp/AnimFlagpoleRed.res"), null, TAB_FURNITURE],
116 : ["Blue Flag", "TEMP", preload("res://dk_images/furniture/flagpole_blueflag_tp/AnimFlagpoleBlue.res"), null, TAB_FURNITURE],
117 : ["Green Flag", "TEMP", preload("res://dk_images/furniture/flagpole_greenflag_tp/AnimFlagpoleGreen.res"), null, TAB_FURNITURE],
118 : ["Yellow Flag", "TEMP", preload("res://dk_images/furniture/flagpole_yellowflag_tp/AnimFlagpoleYellow.res"), null, TAB_FURNITURE],
119 : ["Flagpole", "TEMP", preload("res://dk_images/furniture/flagpole_empty_tp/r1frame01.png"), null, TAB_FURNITURE],
120 : ["Blue Heart Flame", "TEMP", preload("res://dk_images/magic_fogs/anim0802/AnimBlueHeartFlame.res"), null, TAB_FURNITURE],
121 : ["Green Heart Flame", "TEMP", preload("res://dk_images/magic_fogs/anim0800/AnimGreenHeartFlame.res"), null, TAB_FURNITURE],
122 : ["Yellow Heart Flame", "TEMP", preload("res://dk_images/magic_fogs/anim0799/AnimYellowHeartFlame.res"), null, TAB_FURNITURE],
123 : ["Casted Sight", "TEMP", preload("res://dk_images/magic_fogs/anim0854/AnimCastedSight.res"), null, TAB_MISC],
124 : ["Casted Lightning", "TEMP", null, null, TAB_MISC],
125 : ["Torturer", "TEMP", preload("res://dk_images/furniture/torture_machine_tp/r1frame01.png"), null, TAB_FURNITURE],
126 : ["Lair: Orc", "TEMP", preload("res://edited_images/lair/creature_orc/anim0128/r1frame01.png"), null, TAB_LAIR],
127 : ["Power Hand Gold", "TEMP", preload("res://dk_images/power_hand/anim0782/AnimePowerHandGold.res"), null, TAB_MISC],
128 : ["Spinning Coin", "TEMP", null, null, TAB_MISC],
129 : ["Unlit Statue", "TEMP", preload("res://dk_images/statues/anim0954/r1frame01.png"), null, TAB_DECORATION],
130 : ["Statue 3", "TEMP", preload("res://dk_images/statues/anim0956/r1frame01.png"), null, TAB_DECORATION],
131 : ["Statue 4", "TEMP", preload("res://dk_images/statues/anim0958/r1frame01.png"), null, TAB_DECORATION],
132 : ["Statue 5", "TEMP", preload("res://dk_images/statues/anim0960/r1frame01.png"), null, TAB_DECORATION],
133 : ["Mysterious Box", "TEMP", preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
134 : ["Armageddon", "TEMP", preload("res://dk_images/keepower_64/armagedn_std.png"), null, TAB_SPELL],
135 : ["Possess", "TEMP", preload("res://dk_images/keepower_64/possess_std.png"), null, TAB_SPELL],
136 : ["Gold Bag (100)", "TEMP", preload("res://dk_images/valuables/gold_sack_tp/r1frame01.png"), null, TAB_GOLD],
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

	#OBJECT = 1
	#CREATURE = 5
	#EFFECT = 7
	#TRAP = 8
	#DOOR = 9

var thingsCfgHasBeenRead = false
func read_things_cfg():
	var CODETIME_START = OS.get_ticks_msec()
	thingsCfgHasBeenRead = true
	
	for i in 4:
		match i:
			0:
				var massiveString = attempt_to_open_cfg("OBJECTS.CFG")
				if massiveString is String:
					cfg_objects(massiveString)
					load_custom_images_into_array(DATA_OBJECT, "objects")
			1:
				var massiveString = attempt_to_open_cfg("CREATURE.CFG")
				if massiveString is String:
					cfg_creatures(massiveString)
					load_custom_images_into_array(DATA_CREATURE, "creatures")
			2:
				var massiveString = attempt_to_open_cfg("TRAPDOOR.CFG")
				if massiveString is String:
					cfg_traps(massiveString)
					load_custom_images_into_array(DATA_TRAP, "traps")
			3:
				var massiveString = attempt_to_open_cfg("TRAPDOOR.CFG")
				if massiveString is String:
					cfg_doors(massiveString)
					load_custom_images_into_array(DATA_DOOR, "doors")
	
	print('All thing cfgs read in: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')

func attempt_to_open_cfg(cfgFileName):
	var oGame = Nodelist.list["oGame"]
	var path = oGame.get_precise_filepath(oGame.DK_FXDATA_DIRECTORY, cfgFileName)
	
	var file = File.new()
	if path == "" or file.open(path, File.READ) != OK:
		return -1
	var massiveString = file.get_as_text().to_upper() # Make it easier to read by making it all upper case
	file.close()
	return massiveString

func cfg_creatures(massiveString):
	pass

func cfg_traps(massiveString):
	pass

func cfg_doors(massiveString):
	pass

func cfg_objects(massiveString):
	
	var objectListSections = massiveString.split('[OBJECT',false)
	objectListSections.remove(0) # get rid of the first section since it just contains stuff before [object0]
	objectListSections.remove(0) # get rid of the 2nd section since it's [object0] "null"
	var objectID = 1 # start at [object1]
	for section in objectListSections:
		
		# Initialize empty space for each entry in objects.cfg
		if DATA_OBJECT.has(objectID) == false:
			DATA_OBJECT[objectID] = [null, null, null, null, null]
		
		var bigListOfLines = section.split('\n',false)
		for line in bigListOfLines:
			var componentsOfLine = line.split('=', false)
			if componentsOfLine.size() >= 2:
				
				if componentsOfLine[0].strip_edges() == "NAME":
					var thingCfgName = componentsOfLine[1].strip_edges()
					DATA_OBJECT[objectID][KEEPERFX_ID] = thingCfgName # Always set CFG name
					if DATA_OBJECT[objectID][NAME] == null: # Only change name if it's a newly added item
						DATA_OBJECT[objectID][NAME] = thingCfgName.capitalize()
					
				elif componentsOfLine[0].strip_edges() == "GENRE":
					if DATA_OBJECT[objectID][EDITOR_TAB] == null: # Only change tab if it's a newly added item
						var thingGenre = componentsOfLine[1].strip_edges()
						var thingTab = GENRE_TO_TAB[thingGenre]
						DATA_OBJECT[objectID][EDITOR_TAB] = thingTab
		
		objectID += 1

func load_custom_images_into_array(DATA_ARRAY, thingtypeImageFolder):
	print("Loading /thing-images/" + thingtypeImageFolder + " directory ...")
	var arrayOfFilenames = get_png_files_in_dir(Settings.unearthdata.plus_file("thing-images").plus_file(thingtypeImageFolder))
	for i in arrayOfFilenames:
		var subtypeID = int(i.get_file().get_basename())
		var img = Image.new()
		var err = img.load(i)
		if err == OK:
			var tex = ImageTexture.new()
			tex.create_from_image(img)
			if DATA_ARRAY.has(subtypeID):
				DATA_ARRAY[subtypeID][TEXTURE] = tex


func get_png_files_in_dir(path):
	var array = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
			else:
				if file_name.get_extension().to_upper() == "PNG":
					var fileNumber = file_name.get_file().get_basename()
					if Utils.string_has_letters(fileNumber) == false:
						array.append(path.plus_file(file_name))
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return array


#
#static func thing_text(array):
#	var typeArgument = array[THING_TYPE]
#	var subtypeArgument = array[THING_SUBTYPE]
#
#	match typeArgument:
#		TYPE.NONE: return ''
#		TYPE.ITEM: return DATA_OBJECT[subtypeArgument][NAME]
#		TYPE.CREATURE: return DATA_CREATURE[subtypeArgument][NAME]
#		TYPE.EFFECT: return DATA_EFFECT[subtypeArgument][NAME]
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
#			tmp = DATA_EFFECT[subtypeArgument][PORTRAIT]
#			if tmp == null: tmp = DATA_EFFECT[subtypeArgument][TEXTURE]
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
#			#array[11] = node.sensitiveTile
#			#array[12] = node.sensitiveTile
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
#	SENSITIVE_TILE1 = 11
#	SENSITIVE_TILE2 = 12
#	DOOR_ORIENTATION = 13
#	CREATURE_LEVEL = 14
#	DOOR_LOCKED = 14
#	HEROGATE_NUMBER = 14
#}
