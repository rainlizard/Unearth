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
	TEXTURE = 1
	PORTRAIT = 2 # Keep PORTAIT field "null" if I want to use texture for portrait.
	EDITOR_TAB = 3
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

var DATA_EXTRA = {
1 : ["Action Point", preload("res://Art/ActionPoint.png"), null, TAB_ACTION],
2 : ["Light", preload("res://edited_images/GUIEDIT-1/PIC26.png"), null, TAB_EFFECT],
}

var DATA_DOOR = {
1 : ["Wooden Door", preload("res://dk_images/trapdoor_64/door_pers_wood_std.png"), null, TAB_MISC],
2 : ["Braced Door", preload("res://dk_images/trapdoor_64/door_pers_braced_std.png"), null, TAB_MISC],
3 : ["Iron Door", preload("res://dk_images/trapdoor_64/door_pers_iron_std.png"), null, TAB_MISC],
4 : ["Magic Door", preload("res://dk_images/trapdoor_64/door_pers_magic_std.png"), null, TAB_MISC]
}
var DATA_TRAP = {
1 : ["Boulder Trap", preload("res://dk_images/trapdoor_64/trap_boulder_std.png"), null, TAB_TRAP],
2 : ["Alarm Trap", preload("res://dk_images/trapdoor_64/trap_alarm_std.png"), null, TAB_TRAP],
3 : ["Poison Gas Trap", preload("res://dk_images/trapdoor_64/trap_gas_std.png"), null, TAB_TRAP],
4 : ["Lightning Trap", preload("res://dk_images/trapdoor_64/trap_lightning_std.png"), null, TAB_TRAP],
5 : ["Word of Power Trap", preload("res://dk_images/trapdoor_64/trap_wop_std.png"), null, TAB_TRAP],
6 : ["Lava Trap", preload("res://dk_images/trapdoor_64/trap_lava_std.png"), null, TAB_TRAP],
7 : ["Dummy Trap 2", null, null, TAB_TRAP],
8 : ["Dummy Trap 3", null, null, TAB_TRAP],
9 : ["Dummy Trap 4", null, null, TAB_TRAP],
10 : ["Dummy Trap 5", null, null, TAB_TRAP],
11 : ["Dummy Trap 6", null, null, TAB_TRAP],
12 : ["Dummy Trap 7", null, null, TAB_TRAP],
}
var DATA_EFFECT = {
1 : ["Effect: Lava", preload("res://edited_images/GUIEDIT-1/PIC27.png"), null, TAB_EFFECT],
2 : ["Effect: Dripping Water", preload("res://edited_images/GUIEDIT-1/PIC28.png"), null, TAB_EFFECT],
3 : ["Effect: Rock Fall", preload("res://edited_images/GUIEDIT-1/PIC29.png"), null, TAB_EFFECT],
4 : ["Effect: Entrance Ice", preload("res://edited_images/GUIEDIT-1/PIC30.png"), null, TAB_EFFECT],
5 : ["Effect: Dry Ice", preload("res://edited_images/GUIEDIT-1/PIC31.png"), null, TAB_EFFECT]
}
var DATA_CREATURE = {
01 : ["Wizard",          preload("res://edited_images/creatr_icon_64/wizrd_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_wizrd.png"), TAB_CREATURE],
02 : ["Barbarian",       preload("res://edited_images/creatr_icon_64/barbr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_barbr.png"), TAB_CREATURE],
03 : ["Archer",          preload("res://edited_images/creatr_icon_64/archr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_archr.png"), TAB_CREATURE],
04 : ["Monk",            preload("res://edited_images/creatr_icon_64/monk_std.png"),  preload("res://dk_images/creature_portrait_64/creatr_portrt_monk.png"), TAB_CREATURE],
05 : ["Dwarf",           preload("res://edited_images/creatr_icon_64/dwarf_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_dwrf1.png"), TAB_CREATURE],
06 : ["Knight",          preload("res://edited_images/creatr_icon_64/knght_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_knigh.png"), TAB_CREATURE],
07 : ["Avatar",          preload("res://edited_images/creatr_icon_64/avatr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_avatr.png"), TAB_CREATURE],
08 : ["Tunneller",       preload("res://edited_images/creatr_icon_64/tunlr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_dwrf2.png"), TAB_CREATURE],
09 : ["Witch",           preload("res://edited_images/creatr_icon_64/prsts_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_witch.png"), TAB_CREATURE],
10 : ["Giant",           preload("res://edited_images/creatr_icon_64/giant_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_giant.png"), TAB_CREATURE],
11 : ["Fairy",           preload("res://edited_images/creatr_icon_64/fairy_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_fairy.png"), TAB_CREATURE],
12 : ["Thief",           preload("res://edited_images/creatr_icon_64/thief_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_thief.png"), TAB_CREATURE],
13 : ["Samurai",         preload("res://edited_images/creatr_icon_64/samur_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_samur.png"), TAB_CREATURE],
14 : ["Horned Reaper",   preload("res://edited_images/creatr_icon_64/hornd_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_horny.png"), TAB_CREATURE],
15 : ["Skeleton",        preload("res://edited_images/creatr_icon_64/skelt_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_skelt.png"), TAB_CREATURE],
16 : ["Troll",           preload("res://edited_images/creatr_icon_64/troll_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_troll.png"), TAB_CREATURE],
17 : ["Dragon",          preload("res://edited_images/creatr_icon_64/dragn_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_dragn.png"), TAB_CREATURE],
18 : ["Demon Spawn",     preload("res://edited_images/creatr_icon_64/dspwn_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_spawn.png"), TAB_CREATURE],
19 : ["Fly",             preload("res://edited_images/creatr_icon_64/fly_std.png"),   preload("res://dk_images/creature_portrait_64/creatr_portrt_fly.png"), TAB_CREATURE],
20 : ["Dark Mistress",   preload("res://edited_images/creatr_icon_64/dkmis_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_mistr.png"), TAB_CREATURE],
21 : ["Warlock",         preload("res://edited_images/creatr_icon_64/warlk_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_warlk.png"), TAB_CREATURE],
22 : ["Bile Demon",      preload("res://edited_images/creatr_icon_64/biled_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_biled.png"), TAB_CREATURE],
23 : ["Imp",             preload("res://edited_images/creatr_icon_64/imp_std.png"),   preload("res://dk_images/creature_portrait_64/creatr_portrt_imp.png"), TAB_CREATURE],
24 : ["Beetle",          preload("res://edited_images/creatr_icon_64/bug_std.png"),   preload("res://dk_images/creature_portrait_64/creatr_portrt_bug.png"), TAB_CREATURE],
25 : ["Vampire",         preload("res://edited_images/creatr_icon_64/vampr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_vampr.png"), TAB_CREATURE],
26 : ["Spider",          preload("res://edited_images/creatr_icon_64/spidr_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_spidr.png"), TAB_CREATURE],
27 : ["Hell Hound",      preload("res://edited_images/creatr_icon_64/hound_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_hound.png"), TAB_CREATURE],
28 : ["Ghost",           preload("res://edited_images/creatr_icon_64/ghost_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_ghost.png"), TAB_CREATURE],
29 : ["Tentacle",        preload("res://edited_images/creatr_icon_64/tentc_std.png"), preload("res://dk_images/creature_portrait_64/creatr_portrt_tentc.png"), TAB_CREATURE],
30 : ["Orc",             preload("res://edited_images/creatr_icon_64/orc_std.png"),   preload("res://dk_images/creature_portrait_64/creatr_portrt_orc.png"), TAB_CREATURE],
31 : ["Floating Spirit", preload("res://dk_images/magic_dust/anim0981/r1frame02.png"), preload("res://dk_images/magic_dust/anim0981/r1frame02.png"), TAB_CREATURE] # wrong icon probably
}

var DATA_OBJECT = {
001 : ["Barrel", preload("res://dk_images/other/anim0932/r1frame01.png"), null, TAB_DECORATION],
002 : ["Torch", preload("res://dk_images/other/anim0963/r1frame01.png"), null, TAB_DECORATION], #TAB_FURNITURE
003 : ["Gold Pot (500)", preload("res://dk_images/valuables/gold_pot_tp/AnimGoldPot.res"), null, TAB_GOLD],
004 : ["Lit Statue", preload("res://dk_images/statues/anim0952/AnimLitStatue.res"), null, TAB_DECORATION], #TAB_FURNITURE
005 : ["Dungeon Heart", preload("res://dk_images/crucials/anim0950/AnimDungeonHeart.res"), null, TAB_FURNITURE],
006 : ["Gold Pot (250)", preload("res://dk_images/valuables/gold_pot_tp/AnimGoldPot.res"), null, TAB_GOLD],
007 : ["Unlit Torch", preload("res://dk_images/other/anim0963/r1frame01.png"), null, TAB_DECORATION], #TAB_FURNITURE
008 : ["Glowing Statue", preload("res://dk_images/statues/anim0952/AnimLitStatue.res"), null, TAB_DECORATION], #Lit Statue No Flame # Partially Lit Statue
009 : ["Egg Growing (1)", preload("res://dk_images/food/anim0898/AnimEggGrowing1.res"), null, TAB_MISC],
010 : ["Chicken", preload("res://dk_images/food/anim0822/AnimChicken.res"), null, TAB_MISC],
011 : ["Hand Of Evil", preload("res://edited_images/icon_handofevil.png"), null, TAB_SPELL],
012 : ["Create Imp", preload("res://dk_images/keepower_64/imp_std.png"), null, TAB_SPELL],
013 : ["Must Obey", preload("res://edited_images/mustobey.png"), null, TAB_SPELL],
014 : ["Slap", preload("res://edited_images/icon_slap.png"), null, TAB_SPELL],
015 : ["Sight of Evil", preload("res://dk_images/keepower_64/sight_std.png"), null, TAB_SPELL],
016 : ["Call To Arms", preload("res://dk_images/keepower_64/cta_std.png"), null, TAB_SPELL],
017 : ["Cave-In", preload("res://dk_images/keepower_64/cavein_std.png"), null, TAB_SPELL],
018 : ["Heal", preload("res://dk_images/keepower_64/heal_std.png"), null, TAB_SPELL],
019 : ["Hold Audience", preload("res://dk_images/keepower_64/holdaud_std.png"), null, TAB_SPELL],
020 : ["Lightning Strike", preload("res://dk_images/keepower_64/lightng_std.png"), null, TAB_SPELL],
021 : ["Speed Monster", preload("res://dk_images/keepower_64/speed_std.png"), null, TAB_SPELL],
022 : ["Protect Monster", preload("res://dk_images/keepower_64/armor_std.png"), null, TAB_SPELL],
023 : ["Conceal Monster", preload("res://dk_images/keepower_64/conceal_std.png"), null, TAB_SPELL],
024 : ["Cta Ensign", null, null, TAB_MISC],
025 : ["Room Flag", null, null, TAB_MISC], #TAB_DECORATION
026 : ["Anvil", preload("res://dk_images/furniture/workshop_anvil_tp/r1frame01.png"), null, TAB_FURNITURE],
027 : ["Prison Bar", preload("res://dk_images/other/anim0797/r1frame01.png"), null, TAB_FURNITURE],
028 : ["Candlestick", preload("res://dk_images/furniture/anim0791/r1frame01.png"), null, TAB_DECORATION], #TAB_FURNITURE
029 : ["Gravestone", preload("res://dk_images/furniture/tombstone_tp/r1frame01.png"), null, TAB_FURNITURE],
030 : ["Aztec Statue", preload("res://dk_images/statues/anim0907/r1frame01.png"), null, TAB_DECORATION], #TAB_FURNITURE
031 : ["Training Post", preload("res://dk_images/furniture/training_machine_tp/AnimTrainingMachine.res"), null, TAB_FURNITURE],
032 : ["Torture Spike", preload("res://dk_images/furniture/anim0892/AnimSpike.res"), null, TAB_FURNITURE],
033 : ["Temple Spangle", preload("res://dk_images/magic_fogs/anim0798/AnimTempleSpangle.res"), null, TAB_DECORATION],
034 : ["Purple Potion", preload("res://dk_images/potions/anim0804/r1frame01.png"), null, TAB_DECORATION],
035 : ["Blue Potion", preload("res://dk_images/potions/anim0806/r1frame01.png"), null, TAB_DECORATION],
036 : ["Green Potion", preload("res://dk_images/potions/anim0808/r1frame01.png"), null, TAB_DECORATION],
037 : ["Power Hand", preload("res://dk_images/power_hand/anim0783/AnimePowerHand.res"), null, TAB_MISC],
038 : ["Power Hand Grab", preload("res://dk_images/power_hand/anim0784/AnimePowerHandGrab.res"), null, TAB_MISC],
039 : ["Power Hand Whip", preload("res://dk_images/power_hand/anim0786/AnimePowerHandWhip.res"), null, TAB_MISC],
040 : ["Egg Stable (2)", preload("res://dk_images/food/anim0899/r1frame01.png"), null, TAB_MISC],
041 : ["Egg Wobbling (3)", preload("res://dk_images/food/anim0900/AnimEggWobbling3.res"), null, TAB_MISC],
042 : ["Egg Cracking (4)", preload("res://dk_images/food/anim0901/AnimEggCracking4.res"), null, TAB_MISC],
043 : ["Gold Pile (200)", preload("res://dk_images/valuables/gold_hoard1_tp/AnimGoldHoard1.res"), null, TAB_GOLD],
044 : ["Spinning Key", preload("res://dk_images/traps_doors/anim0811/AnimSpinningKey.res"), null, TAB_MISC],
045 : ["Disease", preload("res://dk_images/keepower_64/disease_std.png"), null, TAB_SPELL],
046 : ["Chicken Spell", preload("res://dk_images/keepower_64/chicken_std.png"), null, TAB_SPELL],
047 : ["Destroy Walls", preload("res://dk_images/keepower_64/dstwall_std.png"), null, TAB_SPELL],
048 : ["Time Bomb", preload("res://edited_images/timebomb.png"), null, TAB_SPELL], 
049 : ["Hero Gate", preload("res://dk_images/crucials/anim0780/AnimHeroGate.res"), null, TAB_ACTION],
050 : ["Spinning Key 2", preload("res://dk_images/traps_doors/anim0811/AnimSpinningKey.res"), null, TAB_MISC],
051 : ["Armour Effect", null, null, TAB_MISC],
052 : ["Treasury Gold 1 (800)", preload("res://dk_images/valuables/gold_hoard1_tp/AnimGoldHoard1.res"), null, TAB_GOLD],
053 : ["Treasury Gold 2 (1200)", preload("res://dk_images/valuables/gold_hoard2_tp/AnimGoldHoard2.res"), null, TAB_GOLD],
054 : ["Treasury Gold 3 (1600)", preload("res://dk_images/valuables/gold_hoard3_tp/AnimGoldHoard3.res"), null, TAB_GOLD],
055 : ["Treasury Gold 4 (2000)", preload("res://dk_images/valuables/gold_hoard4_tp/AnimGoldHoard4.res"), null, TAB_GOLD],
056 : ["Treasury Gold 5 (2400)", preload("res://dk_images/valuables/gold_hoard5_tp/AnimGoldHoard5.res"), null, TAB_GOLD],
057 : ["Lair: Wizard", preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.res"), null, TAB_LAIR],
058 : ["Lair: Barbarian", preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.res"), null, TAB_LAIR],
059 : ["Lair: Archer", preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.res"), null, TAB_LAIR],
060 : ["Lair: Monk", preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.res"), null, TAB_LAIR],
061 : ["Lair: Dwarf", preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.res"), null, TAB_LAIR],
062 : ["Lair: Knight", preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.res"), null, TAB_LAIR],
063 : ["Lair: Avatar", preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.res"), null, TAB_LAIR],
064 : ["Lair: Tunneller", preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.res"), null, TAB_LAIR],
065 : ["Lair: Witch", preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.res"), null, TAB_LAIR],
066 : ["Lair: Giant", preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.res"), null, TAB_LAIR],
067 : ["Lair: Fairy", preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.res"), null, TAB_LAIR],
068 : ["Lair: Thief", preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.res"), null, TAB_LAIR],
069 : ["Lair: Samurai", preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.res"), null, TAB_LAIR],
070 : ["Lair: Horny", preload("res://edited_images/lair/creature_horny/anim0160/AnimLairHornedReaper.res"), null, TAB_LAIR],
071 : ["Lair: Skeleton", preload("res://edited_images/lair/creature_skeleton/anim0158/AnimLairSkeleton.res"), null, TAB_LAIR],
072 : ["Lair: Troll", preload("res://edited_images/lair/creature_generic/anim0156/r1frame01.png"), null, TAB_LAIR],
073 : ["Lair: Dragon", preload("res://edited_images/lair/creature_dragon/anim0154/AnimLairDragon.res"), null, TAB_LAIR],
074 : ["Lair: Demon Spawn", preload("res://edited_images/lair/creature_demonspawn/lairempty_tp/r1frame01.png"), null, TAB_LAIR],
075 : ["Lair: Fly", preload("res://edited_images/lair/creature_fly/anim0150/AnimLairFly.res"), null, TAB_LAIR],
076 : ["Lair: Mistress", preload("res://edited_images/lair/creature_dkmistress/anim0148/AnimLairMistress.res"), null, TAB_LAIR],
077 : ["Lair: Warlock", preload("res://edited_images/lair/creature_warlock/anim0146/AnimLairWarlock.res"), null, TAB_LAIR],
078 : ["Lair: Bile Demon", preload("res://edited_images/lair/creature_biledemon/anim0144/AnimLairBileDemon.res"), null, TAB_LAIR],
079 : ["Lair: Imp", preload("res://edited_images/lair/creature_dragon/anim0154/r1frame01.png"), null, TAB_LAIR],
080 : ["Lair: Beetle", preload("res://edited_images/lair/creature_bug/anim0142/AnimLairBeetle.res"), null, TAB_LAIR],
081 : ["Lair: Vampire", preload("res://edited_images/lair/creature_vampire/anim0140/r1frame01.png"), null, TAB_LAIR],
082 : ["Lair: Spider", preload("res://edited_images/lair/creature_spider/anim0138/AnimLairSpider.res"), null, TAB_LAIR],
083 : ["Lair: Hell Hound", preload("res://edited_images/lair/creature_hound/anim0136/r1frame01.png"), null, TAB_LAIR],
084 : ["Lair: Ghost", preload("res://edited_images/lair/creature_ghost/anim0134/r1frame01.png"), null, TAB_LAIR],
085 : ["Lair: Tentacle", preload("res://edited_images/lair/creature_tentacle/anim0130/r1frame01.png"), null, TAB_LAIR],
086 : ["Reveal Map", preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
087 : ["Resurrect Creature", preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
088 : ["Transfer Creature", preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
089 : ["Steal Hero", preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
090 : ["Multiply Creatures", preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
091 : ["Increase Level", preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
092 : ["Make Safe", preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
093 : ["Locate Hidden World", preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
094 : ["Box: Boulder Trap", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
095 : ["Box: Alarm Trap", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
096 : ["Box: Poison Gas Trap", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
097 : ["Box: Lightning Trap", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
098 : ["Box: Word of Power Trap", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
099 : ["Box: Lava Trap", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
100 : ["Box: Dummy Trap 2", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
101 : ["Box: Dummy Trap 3", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
102 : ["Box: Dummy Trap 4", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
103 : ["Box: Dummy Trap 5", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
104 : ["Box: Dummy Trap 6", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
105 : ["Box: Dummy Trap 7", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
106 : ["Box: Wooden Door", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
107 : ["Box: Braced Door", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
108 : ["Box: Iron Door", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
109 : ["Box: Magic Door", preload("res://dk_images/traps_doors/anim0116/AnimBox.res"), null, TAB_BOX],
110 : ["Workshop Item", preload("res://dk_images/furniture/workshop_anvil_tp/r1frame01.png"), null, TAB_MISC],
111 : ["Red Heart Flame", preload("res://dk_images/magic_fogs/anim0801/AnimRedHeartFlame.res"), null, TAB_FURNITURE],
112 : ["Disease Effect", null, null, TAB_MISC],
113 : ["Scavenger Eye", preload("res://dk_images/furniture/scavenge_eye_tp/AnimScavengerEye.res"), null, TAB_FURNITURE],
114 : ["Workshop Machine", preload("res://dk_images/furniture/workshop_machine_tp/AnimWorkshopMachine.res"), null, TAB_FURNITURE],
115 : ["Red Flag", preload("res://dk_images/furniture/flagpole_redflag_tp/AnimFlagpoleRed.res"), null, TAB_FURNITURE],
116 : ["Blue Flag", preload("res://dk_images/furniture/flagpole_blueflag_tp/AnimFlagpoleBlue.res"), null, TAB_FURNITURE],
117 : ["Green Flag", preload("res://dk_images/furniture/flagpole_greenflag_tp/AnimFlagpoleGreen.res"), null, TAB_FURNITURE],
118 : ["Yellow Flag", preload("res://dk_images/furniture/flagpole_yellowflag_tp/AnimFlagpoleYellow.res"), null, TAB_FURNITURE],
119 : ["Flagpole", preload("res://dk_images/furniture/flagpole_empty_tp/r1frame01.png"), null, TAB_FURNITURE],
120 : ["Blue Heart Flame", preload("res://dk_images/magic_fogs/anim0802/AnimBlueHeartFlame.res"), null, TAB_FURNITURE],
121 : ["Green Heart Flame", preload("res://dk_images/magic_fogs/anim0800/AnimGreenHeartFlame.res"), null, TAB_FURNITURE],
122 : ["Yellow Heart Flame", preload("res://dk_images/magic_fogs/anim0799/AnimYellowHeartFlame.res"), null, TAB_FURNITURE],
123 : ["Casted Sight", preload("res://dk_images/magic_fogs/anim0854/AnimCastedSight.res"), null, TAB_MISC],
124 : ["Casted Lightning", null, null, TAB_MISC],
125 : ["Torturer", preload("res://dk_images/furniture/torture_machine_tp/r1frame01.png"), null, TAB_FURNITURE],
126 : ["Lair: Orc", preload("res://edited_images/lair/creature_orc/anim0128/r1frame01.png"), null, TAB_LAIR],
127 : ["Power Hand Gold", preload("res://dk_images/power_hand/anim0782/AnimePowerHandGold.res"), null, TAB_MISC],
128 : ["Spinning Coin", null, null, TAB_MISC],
129 : ["Unlit Statue", preload("res://dk_images/statues/anim0954/r1frame01.png"), null, TAB_DECORATION],
130 : ["Statue 3", preload("res://dk_images/statues/anim0956/r1frame01.png"), null, TAB_DECORATION],
131 : ["Statue 4", preload("res://dk_images/statues/anim0958/r1frame01.png"), null, TAB_DECORATION],
132 : ["Statue 5", preload("res://dk_images/statues/anim0960/r1frame01.png"), null, TAB_DECORATION],
133 : ["Mysterious Box", preload("res://dk_images/trapdoor_64/bonus_box_std.png"), null, TAB_SPECIAL],
134 : ["Armageddon", preload("res://dk_images/keepower_64/armagedn_std.png"), null, TAB_SPELL],
135 : ["Possess", preload("res://dk_images/keepower_64/possess_std.png"), null, TAB_SPELL],
136 : ["Gold Bag (100)", preload("res://dk_images/valuables/gold_sack_tp/r1frame01.png"), null, TAB_GOLD],
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
