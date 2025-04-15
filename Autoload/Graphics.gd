extends Node

func load_extra_images_from_harddrive():
	var CODETIME_START = OS.get_ticks_msec()
	var custom_images_dir = Settings.unearthdata.plus_file("custom-object-images")
	var image_paths = Utils.get_filetype_in_directory(custom_images_dir, "png")
	for image_path in image_paths:
		var texture = Utils.load_external_texture(image_path)
		if texture is ImageTexture:
			var image_name = image_path.get_file().get_basename().to_upper()
			sprite_id[image_name] = texture
		else:
			print("Failed to load texture: ", image_path)
	print('Loaded extra images from HDD: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')

# The keys can be integers or strings (as read from objects.cfg's AnimationID field)
# When they're a String, they can be either read the 'Name' field or the 'AnimationID' field, whichever one is prioritized
var sprite_id = {
# Spellbook objects
"SPELLBOOK_ARMG" : preload("res://dk_images/keepower_64/armagedn_std.png"),
"SPELLBOOK_POSS" : preload("res://dk_images/keepower_64/possess_std.png"),
"SPELLBOOK_HOE" : preload("res://edited_images/icon_handofevil.png"),
"SPELLBOOK_IMP" : preload("res://dk_images/keepower_64/imp_std.png"),
"SPELLBOOK_OBEY" : preload("res://edited_images/mustobey.png"),
"SPELLBOOK_SLAP" : preload("res://edited_images/icon_slap.png"),
"SPELLBOOK_SOE" : preload("res://dk_images/keepower_64/sight_std.png"),
"SPELLBOOK_CTA" : preload("res://dk_images/keepower_64/cta_std.png"),
"SPELLBOOK_CAVI" : preload("res://dk_images/keepower_64/cavein_std.png"),
"SPELLBOOK_HEAL" : preload("res://dk_images/keepower_64/heal_std.png"),
"SPELLBOOK_HLDAUD" : preload("res://dk_images/keepower_64/holdaud_std.png"),
"SPELLBOOK_LIGHTN" : preload("res://dk_images/keepower_64/lightng_std.png"),
"SPELLBOOK_SPDC" : preload("res://dk_images/keepower_64/speed_std.png"),
"SPELLBOOK_PROT" : preload("res://dk_images/keepower_64/armor_std.png"),
"SPELLBOOK_CONCL" : preload("res://dk_images/keepower_64/conceal_std.png"),
"SPELLBOOK_DISEASE" : preload("res://dk_images/keepower_64/disease_std.png"),
"SPELLBOOK_CHKN" : preload("res://dk_images/keepower_64/chicken_std.png"),
"SPELLBOOK_DWAL" : preload("res://dk_images/keepower_64/dstwall_std.png"),
"SPELLBOOK_TBMB" : preload("res://edited_images/timebomb.png"),
"SPELLBOOK_RBND" : preload("res://dk_images/crspell_64/rebound_std.png"),
"SPELLBOOK_FRZ" : preload("res://edited_images/freeze.png"),
"SPELLBOOK_SLOW" : preload("res://dk_images/crspell_64/slowdn_std.png"),
"SPELLBOOK_FLGT" : preload("res://dk_images/crspell_64/flight_std.png"),
"SPELLBOOK_VSN" : preload("res://edited_images/vision.png"),
"SPELLBOOK_TUNLR" : preload("res://edited_images/tunlr.png"),
# Objects
046 : preload("res://dk_images/furniture/torture_machine_tp/r1frame01.png"),
098 : preload("res://dk_images/furniture/workshop_machine_tp/AnimWorkshopMachine.tres"),
100 : preload("res://dk_images/furniture/flagpole_empty_tp/r1frame01.png"),
102 : preload("res://dk_images/furniture/flagpole_redflag_tp/AnimFlagpoleRed.tres"),
104 : preload("res://dk_images/furniture/flagpole_blueflag_tp/AnimFlagpoleBlue.tres"),
106 : preload("res://dk_images/furniture/flagpole_greenflag_tp/AnimFlagpoleGreen.tres"),
108 : preload("res://dk_images/furniture/flagpole_yellowflag_tp/AnimFlagpoleYellow.tres"),
114 : preload("res://dk_images/traps_doors/anim0116/AnimBox.tres"),
124 : preload("res://edited_images/lair/creature_generic/anim0126/AnimLairGeneric.tres"),
126 : preload("res://edited_images/lair/creature_orc/anim0128/r1frame01.png"),
128 : preload("res://edited_images/lair/creature_tentacle/anim0130/r1frame01.png"),
130 : preload("res://dk_images/furniture/scavenge_eye_tp/AnimScavengerEye.tres"),
132 : preload("res://edited_images/lair/creature_ghost/anim0134/r1frame01.png"),
134 : preload("res://edited_images/lair/creature_hound/anim0136/r1frame01.png"),
136 : preload("res://edited_images/lair/creature_spider/anim0138/AnimLairSpider.tres"),
138 : preload("res://edited_images/lair/creature_vampire/anim0140/r1frame01.png"),
140 : preload("res://edited_images/lair/creature_bug/anim0142/AnimLairBeetle.tres"),
142 : preload("res://edited_images/lair/creature_biledemon/anim0144/AnimLairBileDemon.tres"),
144 : preload("res://edited_images/lair/creature_warlock/anim0146/AnimLairWarlock.tres"),
146 : preload("res://edited_images/lair/creature_dkmistress/anim0148/AnimLairMistress.tres"),
148 : preload("res://edited_images/lair/creature_fly/anim0150/AnimLairFly.tres"),
150 : preload("res://edited_images/lair/creature_demonspawn/lairempty_tp/r1frame01.png"),
152 : preload("res://edited_images/lair/creature_dragon/anim0154/AnimLairDragon.tres"),
154 : preload("res://edited_images/lair/creature_generic/anim0156/r1frame01.png"),
156 : preload("res://edited_images/lair/creature_skeleton/anim0158/AnimLairSkeleton.tres"),
158 : preload("res://edited_images/lair/creature_horny/anim0160/AnimLairHornedReaper.tres"),
776 : preload("res://dk_images/crucials/anim0780/AnimHeroGate.tres"),
777 : preload("res://edited_images/icon_book.png"),
781 : preload("res://dk_images/power_hand/anim0782/AnimePowerHandGold.tres"),
782 : preload("res://dk_images/power_hand/anim0783/AnimePowerHand.tres"),
783 : preload("res://dk_images/power_hand/anim0784/AnimePowerHandGrab.tres"),
785 : preload("res://dk_images/power_hand/anim0786/AnimePowerHandWhip.tres"),
789 : preload("res://dk_images/furniture/workshop_anvil_tp/r1frame01.png"),
791 : preload("res://dk_images/furniture/anim0791/r1frame01.png"),
793 : preload("res://dk_images/furniture/tombstone_tp/r1frame01.png"),
795 : preload("res://dk_images/furniture/training_machine_tp/AnimTrainingMachine.tres"),
796 : preload("res://dk_images/other/anim0797/r1frame01.png"),
797 : preload("res://dk_images/magic_fogs/anim0798/AnimTempleSpangle.tres"),
798 : preload("res://dk_images/magic_fogs/anim0801/AnimRedHeartFlame.tres"),
799 : preload("res://dk_images/magic_fogs/anim0802/AnimBlueHeartFlame.tres"),
800 : preload("res://dk_images/magic_fogs/anim0800/AnimGreenHeartFlame.tres"),
801 : preload("res://dk_images/magic_fogs/anim0799/AnimYellowHeartFlame.tres"),
804 : preload("res://dk_images/potions/anim0804/r1frame01.png"),
806 : preload("res://dk_images/potions/anim0806/r1frame01.png"),
808 : preload("res://dk_images/potions/anim0808/r1frame01.png"),
810 : preload("res://dk_images/traps_doors/anim0811/AnimSpinningKey.tres"),
818 : preload("res://dk_images/traps_doors/anim0811/AnimSpinningKey.tres"),
819 : preload("res://dk_images/food/anim0822/AnimChicken.tres"),
892 : preload("res://dk_images/furniture/anim0892/AnimSpike.tres"),
893 : preload("res://dk_images/food/anim0898/AnimEggGrowing1.tres"),
894 : preload("res://dk_images/food/anim0899/r1frame01.png"),
895 : preload("res://dk_images/food/anim0900/AnimEggWobbling3.tres"),
896 : preload("res://dk_images/food/anim0901/AnimEggCracking4.tres"),
901 : preload("res://dk_images/trapdoor_64/bonus_box_std.png"),
905 : preload("res://dk_images/statues/anim0907/r1frame01.png"),
930 : preload("res://dk_images/other/anim0932/r1frame01.png"),
933 : preload("res://dk_images/valuables/gold_sack_tp/r1frame01.png"),
934 : preload("res://dk_images/valuables/gold_pot_tp/AnimGoldPot.tres"),
936 : preload("res://dk_images/valuables/gold_hoard1_tp/AnimGoldHoard1.tres"),
937 : preload("res://dk_images/valuables/gold_hoard2_tp/AnimGoldHoard2.tres"),
938 : preload("res://dk_images/valuables/gold_hoard3_tp/AnimGoldHoard3.tres"),
939 : preload("res://dk_images/valuables/gold_hoard4_tp/AnimGoldHoard4.tres"),
940 : preload("res://dk_images/valuables/gold_hoard5_tp/AnimGoldHoard5.tres"),
948 : preload("res://dk_images/crucials/anim0950/AnimDungeonHeart.tres"),
950 : preload("res://dk_images/statues/anim0952/AnimLitStatue.tres"),
952 : preload("res://dk_images/statues/anim0954/r1frame01.png"),
958 : preload("res://dk_images/statues/anim0960/r1frame01.png"),
962 : preload("res://dk_images/other/anim0963/r1frame01.png"),
# Extras
"ACTIONPOINT" : preload("res://Art/ActionPoint.png"),
"LIGHT" : preload("res://edited_images/GUIEDIT-1/PIC26.png"),
# Doors
"WOOD" : preload("res://dk_images/trapdoor_64/door_pers_wood_std.png"),
"BRACED" : preload("res://dk_images/trapdoor_64/door_pers_braced_std.png"),
"STEEL" : preload("res://dk_images/trapdoor_64/door_pers_iron_std.png"),
"MAGIC" : preload("res://dk_images/trapdoor_64/door_pers_magic_std.png"),
"SECRET" : preload("res://extra_images/secret_door.png"),
"MIDAS" : preload("res://extra_images/midas_door.png"),
# EffectGens
"EFFECTGENERATOR_LAVA" : preload("res://edited_images/GUIEDIT-1/PIC27.png"),
"EFFECTGENERATOR_DRIPPING_WATER" : preload("res://edited_images/GUIEDIT-1/PIC28.png"),
"EFFECTGENERATOR_ROCK_FALL" : preload("res://edited_images/GUIEDIT-1/PIC29.png"),
"EFFECTGENERATOR_ENTRANCE_ICE" : preload("res://edited_images/GUIEDIT-1/PIC30.png"),
"EFFECTGENERATOR_DRY_ICE" : preload("res://edited_images/GUIEDIT-1/PIC31.png"),
# Traps
"BOULDER" : preload("res://dk_images/trapdoor_64/trap_boulder_std.png"),
"ALARM" : preload("res://dk_images/trapdoor_64/trap_alarm_std.png"),
"POISON_GAS" : preload("res://dk_images/trapdoor_64/trap_gas_std.png"),
"LIGHTNING" : preload("res://dk_images/trapdoor_64/trap_lightning_std.png"),
"WORD_OF_POWER" : preload("res://dk_images/trapdoor_64/trap_wop_std.png"),
"LAVA" : preload("res://dk_images/trapdoor_64/trap_lava_std.png"),
"TNT" : preload("res://extra_images/tnt.png"),
# Decorations/Furniture
"BANNER" : preload("res://extra_images/banner.png"),
"FERN" : preload("res://extra_images/fern.png"),
"FERN_BROWN" : preload("res://extra_images/fern_brown.png"),
"FERN_SMALL" : preload("res://extra_images/fern_small.png"),
"FERN_SMALL_BROWN" : preload("res://extra_images/fern_small_brown.png"),
"FLAGPOLE_BLACKFLAG" : preload("res://dk_images/furniture/flagpole_blackflag_tp/AnimFlagpoleBlack.tres"),
"FLAGPOLE_ORANGEFLAG" : preload("res://dk_images/furniture/flagpole_orangeflag_tp/AnimFlagpoleOrange.tres"),
"FLAGPOLE_PURPLEFLAG" : preload("res://dk_images/furniture/flagpole_purpleflag_tp/AnimFlagpolePurple.tres"),
"FLAGPOLE_WHITEFLAG" : preload("res://dk_images/furniture/flagpole_whiteflag_tp/AnimFlagpoleWhite.tres"),
"GOLDEN_ARMOR" : preload("res://dk_images/statues/anim0956/r1frame01.png"),
"HEARTFLAME_BLACK" : preload("res://edited_images/heartflames/heartflame_black/AnimBlackHeartFlame.tres"),
"HEARTFLAME_ORANGE" : preload("res://edited_images/heartflames/heartflame_orange/AnimOrangeHeartFlame.tres"),
"HEARTFLAME_PURPLE" : preload("res://edited_images/heartflames/heartflame_purple/AnimPurpleHeartFlame.tres"),
"HEARTFLAME_WHITE" : preload("res://edited_images/heartflames/heartflame_white/AnimWhiteHeartFlame.tres"),
"ICE_PILLAR" : preload("res://extra_images/ice_pillar.png"),
"ICE_PILLAR_SMALL" : preload("res://extra_images/ice_rock.png"),
"JUNGLE_CATTAILS" : preload("res://extra_images/cattails.png"),
"JUNGLE_LILYPAD" : preload("res://extra_images/lilypad.png"),
"KNIGHTSTATUE" : preload("res://dk_images/statues/anim0958/r1frame01.png"),
"LANTERNPOST_STAND" : preload("res://extra_images/lantern_pst.png"),
"LAVA_PILLAR" : preload("res://extra_images/lava_pillar.png"),
"LAVA_PILLAR_SMALL" : preload("res://extra_images/lava_rock.png"),
"MUSHROOM_GREEN_LUM" : preload("res://extra_images/mushroom_green.png"),
"MUSHROOM_RED_LUM" : preload("res://extra_images/mushroom_red.png"),
"MUSHROOM_YELLOW_LUM" : preload("res://extra_images/mushroom_yellow.png"),
"POTION_BROWN" : preload("res://extra_images/potion_brown.png"),
"POTION_RED" : preload("res://extra_images/potion_red.png"),
"POTION_WHITE" : preload("res://extra_images/potion_white.png"),
"POTION_YELLOW" : preload("res://extra_images/potion_yellow.png"),
"ROCK_PILLAR" : preload("res://extra_images/rock_pillar.png"),
"ROCK_PILLAR_SMALL" : preload("res://extra_images/rock.png"),
"DRUID_LAIR" : preload("res://extra_images/lair_druid.png"),
"MAIDEN_LAIR" : preload("res://extra_images/lair_maiden.png"),
"SPIDERLING_LAIR" : preload("res://extra_images/lair_spiderling.png"),
# Creatures
"POWER_SIGHT" : preload("res://dk_images/magic_fogs/anim0854/AnimCastedSight.tres"),
"WIZARD" : preload("res://edited_images/creatr_icon_64/wizrd_std.png"),
"WIZARD_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_wizrd.png"),
"BARBARIAN" : preload("res://edited_images/creatr_icon_64/barbr_std.png"),
"BARBARIAN_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_barbr.png"),
"ARCHER" : preload("res://edited_images/creatr_icon_64/archr_std.png"),
"ARCHER_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_archr.png"),
"MONK" : preload("res://edited_images/creatr_icon_64/monk_std.png"),
"MONK_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_monk.png"),
"DWARFA" : preload("res://edited_images/creatr_icon_64/dwarf_std.png"),
"DWARFA_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_dwrf1.png"),
"KNIGHT" : preload("res://edited_images/creatr_icon_64/knght_std.png"),
"KNIGHT_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_knigh.png"),
"AVATAR" : preload("res://edited_images/creatr_icon_64/avatr_std.png"),
"AVATAR_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_avatr.png"),
"TUNNELLER" : preload("res://edited_images/creatr_icon_64/tunlr_std.png"),
"TUNNELLER_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_dwrf2.png"),
"WITCH" : preload("res://edited_images/creatr_icon_64/prsts_std.png"),
"WITCH_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_witch.png"),
"GIANT" : preload("res://edited_images/creatr_icon_64/giant_std.png"),
"GIANT_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_giant.png"),
"FAIRY" : preload("res://edited_images/creatr_icon_64/fairy_std.png"),
"FAIRY_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_fairy.png"),
"THIEF" : preload("res://edited_images/creatr_icon_64/thief_std.png"),
"THIEF_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_thief.png"),
"SAMURAI" : preload("res://edited_images/creatr_icon_64/samur_std.png"),
"SAMURAI_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_samur.png"),
"HORNY" : preload("res://edited_images/creatr_icon_64/hornd_std.png"),
"HORNY_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_horny.png"),
"SKELETON" : preload("res://edited_images/creatr_icon_64/skelt_std.png"),
"SKELETON_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_skelt.png"),
"TROLL" : preload("res://edited_images/creatr_icon_64/troll_std.png"),
"TROLL_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_troll.png"),
"DRAGON" : preload("res://edited_images/creatr_icon_64/dragn_std.png"),
"DRAGON_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_dragn.png"),
"DEMONSPAWN" : preload("res://edited_images/creatr_icon_64/dspwn_std.png"),
"DEMONSPAWN_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_spawn.png"),
"FLY" : preload("res://edited_images/creatr_icon_64/fly_std.png"),
"FLY_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_fly.png"),
"DARK_MISTRESS" : preload("res://edited_images/creatr_icon_64/dkmis_std.png"),
"DARK_MISTRESS_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_mistr.png"),
"SORCEROR" : preload("res://edited_images/creatr_icon_64/warlk_std.png"),
"SORCEROR_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_warlk.png"),
"BILE_DEMON" : preload("res://edited_images/creatr_icon_64/biled_std.png"),
"BILE_DEMON_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_biled.png"),
"IMP" : preload("res://edited_images/creatr_icon_64/imp_std.png"),
"IMP_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_imp.png"),
"BUG" : preload("res://edited_images/creatr_icon_64/bug_std.png"),
"BUG_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_bug.png"),
"VAMPIRE" : preload("res://edited_images/creatr_icon_64/vampr_std.png"),
"VAMPIRE_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_vampr.png"),
"SPIDER" : preload("res://edited_images/creatr_icon_64/spidr_std.png"),
"SPIDER_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_spidr.png"),
"HELL_HOUND" : preload("res://edited_images/creatr_icon_64/hound_std.png"),
"HELL_HOUND_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_hound.png"),
"GHOST" : preload("res://edited_images/creatr_icon_64/ghost_std.png"),
"GHOST_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_ghost.png"),
"TENTACLE" : preload("res://edited_images/creatr_icon_64/tentc_std.png"),
"TENTACLE_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_tentc.png"),
"ORC" : preload("res://edited_images/creatr_icon_64/orc_std.png"),
"ORC_PORTRAIT" : preload("res://dk_images/creature_portrait_64/creatr_portrt_orc.png"),
"FLOATING_SPIRIT" : preload("res://dk_images/magic_dust/anim0981/r1frame02.png"),
"FLOATING_SPIRIT_PORTRAIT" : preload("res://dk_images/magic_dust/anim0981/r1frame02.png"),
"DRUID" : preload("res://extra_images/druid.png"),
"DRUID_PORTRAIT" : preload("res://extra_images/druid_portrait.png"),
"TIME_MAGE" : preload("res://extra_images/time_mage.png"),
"TIME_MAGE_PORTRAIT" : preload("res://extra_images/time_mage_portrait.png"),
"MAIDEN" : preload("res://extra_images/maiden.png"),
"MAIDEN_PORTRAIT" : preload("res://extra_images/maiden_portrait.png"),
"SPIDERLING" : preload("res://extra_images/spiderling.png"),
"SPIDERLING_PORTRAIT" : preload("res://extra_images/spiderling_portrait.png"),
}


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


#func look_for_images_to_load(DATA_ARRAY, objectID, thingCfgName):
#	if custom_images_list.empty() == true:
#		custom_images_list = get_png_filenames_in_dir(Settings.unearthdata.plus_file("custom-object-images"))
#
#	var dir = Settings.unearthdata.plus_file("custom-object-images")
#
#	var uppercaseImageFilename = thingCfgName+".PNG".to_upper()
#	var uppercasePortraitFilename = thingCfgName+"_PORTRAIT.PNG".to_upper()
#
#	var realImageFilename = ""
#	var realPortraitFilename = ""
#
#	if custom_images_list.has(uppercaseImageFilename):
#		 realImageFilename = custom_images_list[uppercaseImageFilename]
#
#	if custom_images_list.has(uppercasePortraitFilename):
#		 realPortraitFilename = custom_images_list[uppercasePortraitFilename]
#
#	if realImageFilename != "":
#		var img = Image.new()
#		var err = img.load(dir.plus_file(realImageFilename))
#		if err == OK:
#			var tex = ImageTexture.new()
#			tex.create_from_image(img, Texture.FLAG_MIPMAPS+Texture.FLAG_ANISOTROPIC_FILTER)
#			#DATA_ARRAY[objectID][Things.TEXTURE] = tex
#
#	if realPortraitFilename != "":
#		var img = Image.new()
#		var err = img.load(dir.plus_file(realPortraitFilename))
#		if err == OK:
#			var tex = ImageTexture.new()
#			tex.create_from_image(img, Texture.FLAG_MIPMAPS+Texture.FLAG_ANISOTROPIC_FILTER)
#			#DATA_ARRAY[objectID][Things.PORTRAIT] = tex
#
#func get_png_filenames_in_dir(path):
#	var dictionary = {}
#	var dir = Directory.new()
#	if dir.open(path) == OK:
#		dir.list_dir_begin()
#		var file_name = dir.get_next()
#		while file_name != "":
#			if dir.current_is_dir():
#				pass
#			else:
#				if file_name.get_extension().to_upper() == "PNG":
#					dictionary[file_name.to_upper().replace(" ", "_")] = file_name
#			file_name = dir.get_next()
#	else:
#		print("An error occurred when trying to access the path.")
#	return dictionary
#
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

