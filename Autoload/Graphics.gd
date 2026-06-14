extends Node

func load_images_assorted():
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
"SPELLBOOK_ARMG" : preload("res://images_objects/keepower_64/armagedn_std.png"),
"SPELLBOOK_POSS" : preload("res://images_objects/keepower_64/possess_std.png"),
"SPELLBOOK_HOE" : preload("res://images_objects/icon_handofevil.png"),
"SPELLBOOK_IMP" : preload("res://images_objects/keepower_64/imp_std.png"),
"SPELLBOOK_OBEY" : preload("res://images_objects/mustobey.png"),
"SPELLBOOK_SLAP" : preload("res://images_objects/icon_slap.png"),
"SPELLBOOK_SOE" : preload("res://images_objects/keepower_64/sight_std.png"),
"SPELLBOOK_CTA" : preload("res://images_objects/keepower_64/cta_std.png"),
"SPELLBOOK_CAVI" : preload("res://images_objects/keepower_64/cavein_std.png"),
"SPELLBOOK_HEAL" : preload("res://images_objects/keepower_64/heal_std.png"),
"SPELLBOOK_HLDAUD" : preload("res://images_objects/keepower_64/holdaud_std.png"),
"SPELLBOOK_LIGHTN" : preload("res://images_objects/keepower_64/lightng_std.png"),
"SPELLBOOK_SPDC" : preload("res://images_objects/keepower_64/speed_std.png"),
"SPELLBOOK_PROT" : preload("res://images_objects/keepower_64/armor_std.png"),
"SPELLBOOK_CONCL" : preload("res://images_objects/keepower_64/conceal_std.png"),
"SPELLBOOK_DISEASE" : preload("res://images_objects/keepower_64/disease_std.png"),
"SPELLBOOK_CHKN" : preload("res://images_objects/keepower_64/chicken_std.png"),
"SPELLBOOK_DWAL" : preload("res://images_objects/keepower_64/dstwall_std.png"),
"SPELLBOOK_TBMB" : preload("res://images_objects/timebomb.png"),
"SPELLBOOK_RBND" : preload("res://dk_images/crspell_64/rebound_std.png"),
"SPELLBOOK_FRZ" : preload("res://images_assorted/freeze.png"),
"SPELLBOOK_SLOW" : preload("res://dk_images/crspell_64/slowdn_std.png"),
"SPELLBOOK_FLGT" : preload("res://dk_images/crspell_64/flight_std.png"),
"SPELLBOOK_VSN" : preload("res://images_assorted/vision.png"),
"SPELLBOOK_TUNLR" : preload("res://images_assorted/tunlr.png"),
# Objects
046 : preload("res://images_objects/furniture/torture_machine_tp/r1frame01.png"),
098 : preload("res://images_objects/furniture/workshop_machine_tp/AnimWorkshopMachine.tres"),
100 : preload("res://images_objects/furniture/flagpole_empty_tp/r1frame01.png"),
102 : preload("res://images_objects/furniture/flagpole_redflag_tp/AnimFlagpoleRed.tres"),
104 : preload("res://images_objects/furniture/flagpole_blueflag_tp/AnimFlagpoleBlue.tres"),
106 : preload("res://images_objects/furniture/flagpole_greenflag_tp/AnimFlagpoleGreen.tres"),
108 : preload("res://images_objects/furniture/flagpole_yellowflag_tp/AnimFlagpoleYellow.tres"),
114 : preload("res://images_objects/traps_doors/anim0116/AnimBox.tres"),
124 : preload("res://images_objects/lair/creature_generic/anim0126/AnimLairGeneric.tres"),
126 : preload("res://images_objects/lair/creature_orc/anim0128/r1frame01.png"),
128 : preload("res://images_objects/lair/creature_tentacle/anim0130/r1frame01.png"),
130 : preload("res://images_objects/furniture/scavenge_eye_tp/AnimScavengerEye.tres"),
132 : preload("res://images_objects/lair/creature_ghost/anim0134/r1frame01.png"),
134 : preload("res://images_objects/lair/creature_hound/anim0136/r1frame01.png"),
136 : preload("res://images_objects/lair/creature_spider/anim0138/AnimLairSpider.tres"),
138 : preload("res://images_objects/lair/creature_vampire/anim0140/r1frame01.png"),
140 : preload("res://images_objects/lair/creature_bug/anim0142/AnimLairBeetle.tres"),
142 : preload("res://images_objects/lair/creature_biledemon/anim0144/AnimLairBileDemon.tres"),
144 : preload("res://images_objects/lair/creature_warlock/anim0146/AnimLairWarlock.tres"),
146 : preload("res://images_objects/lair/creature_dkmistress/anim0148/AnimLairMistress.tres"),
148 : preload("res://images_objects/lair/creature_fly/anim0150/AnimLairFly.tres"),
150 : preload("res://images_objects/lair/creature_demonspawn/lairempty_tp/r1frame01.png"),
152 : preload("res://images_objects/lair/creature_dragon/anim0154/AnimLairDragon.tres"),
154 : preload("res://images_objects/lair/creature_generic/anim0156/r1frame01.png"),
156 : preload("res://images_objects/lair/creature_skeleton/anim0158/AnimLairSkeleton.tres"),
158 : preload("res://images_objects/lair/creature_horny/anim0160/AnimLairHornedReaper.tres"),
776 : preload("res://images_objects/crucials/anim0780/AnimHeroGate.tres"),
777 : preload("res://images_assorted/icon_book.png"),
781 : preload("res://images_objects/power_hand/anim0782/AnimePowerHandGold.tres"),
782 : preload("res://images_objects/power_hand/anim0783/AnimePowerHand.tres"),
783 : preload("res://images_objects/power_hand/anim0784/AnimePowerHandGrab.tres"),
785 : preload("res://images_objects/power_hand/anim0786/AnimePowerHandWhip.tres"),
789 : preload("res://images_objects/furniture/workshop_anvil_tp/r1frame01.png"),
791 : preload("res://images_objects/furniture/anim0791/r1frame01.png"),
793 : preload("res://images_objects/furniture/tombstone_tp/r1frame01.png"),
795 : preload("res://images_objects/furniture/training_machine_tp/AnimTrainingMachine.tres"),
796 : preload("res://images_objects/other/anim0797/r1frame01.png"),
797 : preload("res://images_objects/magic_fogs/anim0798/AnimTempleSpangle.tres"),
798 : preload("res://images_objects/magic_fogs/anim0801/AnimRedHeartFlame.tres"),
799 : preload("res://images_objects/magic_fogs/anim0802/AnimBlueHeartFlame.tres"),
800 : preload("res://images_objects/magic_fogs/anim0800/AnimGreenHeartFlame.tres"),
801 : preload("res://images_objects/magic_fogs/anim0799/AnimYellowHeartFlame.tres"),
804 : preload("res://images_objects/potions/anim0804/r1frame01.png"),
806 : preload("res://images_objects/potions/anim0806/r1frame01.png"),
808 : preload("res://images_objects/potions/anim0808/r1frame01.png"),
810 : preload("res://images_objects/traps_doors/anim0811/AnimSpinningKey.tres"),
818 : preload("res://images_objects/traps_doors/anim0811/AnimSpinningKey.tres"),
819 : preload("res://images_objects/food/anim0822/AnimChicken.tres"),
892 : preload("res://images_objects/furniture/anim0892/AnimSpike.tres"),
893 : preload("res://images_objects/food/anim0898/AnimEggGrowing1.tres"),
894 : preload("res://images_objects/food/anim0899/r1frame01.png"),
895 : preload("res://images_objects/food/anim0900/AnimEggWobbling3.tres"),
896 : preload("res://images_objects/food/anim0901/AnimEggCracking4.tres"),
901 : preload("res://images_objects/trapdoor_64/bonus_box_std.png"),
905 : preload("res://images_objects/statues/anim0907/r1frame01.png"),
930 : preload("res://images_objects/other/anim0932/r1frame01.png"),
933 : preload("res://dk_images/valuables/gold_sack_tp/r1frame01.png"),
934 : preload("res://images_objects/valuables/gold_pot_tp/AnimGoldPot.tres"),
936 : preload("res://images_objects/valuables/gold_hoard1_tp/AnimGoldHoard1.tres"),
937 : preload("res://images_objects/valuables/gold_hoard2_tp/AnimGoldHoard2.tres"),
938 : preload("res://images_objects/valuables/gold_hoard3_tp/AnimGoldHoard3.tres"),
939 : preload("res://images_objects/valuables/gold_hoard4_tp/AnimGoldHoard4.tres"),
940 : preload("res://images_objects/valuables/gold_hoard5_tp/AnimGoldHoard5.tres"),
948 : preload("res://images_objects/crucials/anim0950/AnimDungeonHeart.tres"),
950 : preload("res://images_objects/statues/anim0952/AnimLitStatue.tres"),
952 : preload("res://images_objects/statues/anim0954/r1frame01.png"),
958 : preload("res://images_objects/statues/anim0960/r1frame01.png"),
962 : preload("res://images_objects/other/anim0963/r1frame01.png"),
# Extras
"ACTIONPOINT" : preload("res://Art/ActionPoint.png"),
"LIGHT" : preload("res://images_assorted/GUIEDIT-1/PIC26.png"),
# Doors
"WOOD" : preload("res://dk_images/trapdoor_64/door_pers_wood_std.png"),
"BRACED" : preload("res://dk_images/trapdoor_64/door_pers_braced_std.png"),
"STEEL" : preload("res://dk_images/trapdoor_64/door_pers_iron_std.png"),
"MAGIC" : preload("res://dk_images/trapdoor_64/door_pers_magic_std.png"),
"SECRET" : preload("res://images_assorted/secret_door.png"),
"MIDAS" : preload("res://images_assorted/midas_door.png"),
# EffectGens
"EFFECTGENERATOR_LAVA" : preload("res://images_assorted/GUIEDIT-1/PIC27.png"),
"EFFECTGENERATOR_DRIPPING_WATER" : preload("res://images_assorted/GUIEDIT-1/PIC28.png"),
"EFFECTGENERATOR_ROCK_FALL" : preload("res://images_assorted/GUIEDIT-1/PIC29.png"),
"EFFECTGENERATOR_ENTRANCE_ICE" : preload("res://images_assorted/GUIEDIT-1/PIC30.png"),
"EFFECTGENERATOR_DRY_ICE" : preload("res://images_assorted/GUIEDIT-1/PIC31.png"),
# Traps
"BOULDER" : preload("res://dk_images/trapdoor_64/trap_boulder_std.png"),
"ALARM" : preload("res://dk_images/trapdoor_64/trap_alarm_std.png"),
"POISON_GAS" : preload("res://dk_images/trapdoor_64/trap_gas_std.png"),
"LIGHTNING" : preload("res://dk_images/trapdoor_64/trap_lightning_std.png"),
"WORD_OF_POWER" : preload("res://dk_images/trapdoor_64/trap_wop_std.png"),
"LAVA" : preload("res://dk_images/trapdoor_64/trap_lava_std.png"),
"TNT" : preload("res://images_assorted/tnt.png"),
"SENTRY" : preload("res://images_assorted/sentry.png"),
"BALLISTA" : preload("res://images_assorted/ballista.png"),

# Decorations/Furniture
"BANNER" : preload("res://images_objects/banner.png"),
"FERN" : preload("res://images_objects/fern.png"),
"FERN_BROWN" : preload("res://images_objects/fern_brown.png"),
"FERN_SMALL" : preload("res://images_objects/fern_small.png"),
"FERN_SMALL_BROWN" : preload("res://images_objects/fern_small_brown.png"),
"FLAGPOLE_BLACKFLAG" : preload("res://images_objects/furniture/flagpole_blackflag_tp/AnimFlagpoleBlack.tres"),
"FLAGPOLE_ORANGEFLAG" : preload("res://images_objects/furniture/flagpole_orangeflag_tp/AnimFlagpoleOrange.tres"),
"FLAGPOLE_PURPLEFLAG" : preload("res://images_objects/furniture/flagpole_purpleflag_tp/AnimFlagpolePurple.tres"),
"FLAGPOLE_WHITEFLAG" : preload("res://images_objects/furniture/flagpole_whiteflag_tp/AnimFlagpoleWhite.tres"),
"GOLDEN_ARMOR" : preload("res://images_objects/statues/anim0956/r1frame01.png"),
"HEARTFLAME_BLACK" : preload("res://images_objects/heartflames/heartflame_black/AnimBlackHeartFlame.tres"),
"HEARTFLAME_ORANGE" : preload("res://images_objects/heartflames/heartflame_orange/AnimOrangeHeartFlame.tres"),
"HEARTFLAME_PURPLE" : preload("res://images_objects/heartflames/heartflame_purple/AnimPurpleHeartFlame.tres"),
"HEARTFLAME_WHITE" : preload("res://images_objects/heartflames/heartflame_white/AnimWhiteHeartFlame.tres"),
"ICE_PILLAR" : preload("res://images_objects/ice_pillar.png"),
"ICE_PILLAR_SMALL" : preload("res://images_objects/ice_rock.png"),
"JUNGLE_CATTAILS" : preload("res://images_objects/cattails.png"),
"JUNGLE_LILYPAD" : preload("res://images_objects/lilypad.png"),
"KNIGHTSTATUE" : preload("res://images_objects/statues/anim0958/r1frame01.png"),
"LANTERNPOST_STAND" : preload("res://images_objects/lantern_pst.png"),
"LAVA_PILLAR" : preload("res://images_objects/lava_pillar.png"),
"LAVA_PILLAR_SMALL" : preload("res://images_objects/lava_rock.png"),
"MUSHROOM_GREEN_LUM" : preload("res://images_objects/mushroom_green.png"),
"MUSHROOM_RED_LUM" : preload("res://images_objects/mushroom_red.png"),
"MUSHROOM_YELLOW_LUM" : preload("res://images_objects/mushroom_yellow.png"),
"POTION_BROWN" : preload("res://images_objects/potion_brown.png"),
"POTION_RED" : preload("res://images_objects/potion_red.png"),
"POTION_WHITE" : preload("res://images_objects/potion_white.png"),
"POTION_YELLOW" : preload("res://images_objects/potion_yellow.png"),
"ROCK_PILLAR" : preload("res://images_objects/rock_pillar.png"),
"ROCK_PILLAR_SMALL" : preload("res://images_objects/rock.png"),
"DRUID_LAIR" : preload("res://images_objects/lair_druid.png"),
"MAIDEN_LAIR" : preload("res://images_objects/lair_maiden.png"),
"SPIDERLING_LAIR" : preload("res://images_objects/lair_spiderling.png"),
"BIRD_LAIR" : preload("res://images_objects/lair_bird.png"),
# Creatures
"POWER_SIGHT" : preload("res://images_objects/magic_fogs/anim0854/AnimCastedSight.tres"),
"WIZARD" : preload("res://images_creatures/wizrd_std.png"),
"WIZARD_PORTRAIT" : preload("res://images_creatures/creatr_portrt_wizrd.png"),
"BARBARIAN" : preload("res://images_creatures/barbr_std.png"),
"BARBARIAN_PORTRAIT" : preload("res://images_creatures/creatr_portrt_barbr.png"),
"ARCHER" : preload("res://images_creatures/archr_std.png"),
"ARCHER_PORTRAIT" : preload("res://images_creatures/creatr_portrt_archr.png"),
"MONK" : preload("res://images_creatures/monk_std.png"),
"MONK_PORTRAIT" : preload("res://images_creatures/creatr_portrt_monk.png"),
"DWARFA" : preload("res://images_creatures/dwarf_std.png"),
"DWARFA_PORTRAIT" : preload("res://images_creatures/creatr_portrt_dwrf1.png"),
"KNIGHT" : preload("res://images_creatures/knght_std.png"),
"KNIGHT_PORTRAIT" : preload("res://images_creatures/creatr_portrt_knigh.png"),
"AVATAR" : preload("res://images_creatures/avatr_std.png"),
"AVATAR_PORTRAIT" : preload("res://images_creatures/creatr_portrt_avatr.png"),
"TUNNELLER" : preload("res://images_creatures/tunlr_std.png"),
"TUNNELLER_PORTRAIT" : preload("res://images_creatures/creatr_portrt_dwrf2.png"),
"WITCH" : preload("res://images_creatures/prsts_std.png"),
"WITCH_PORTRAIT" : preload("res://images_creatures/creatr_portrt_witch.png"),
"GIANT" : preload("res://images_creatures/giant_std.png"),
"GIANT_PORTRAIT" : preload("res://images_creatures/creatr_portrt_giant.png"),
"FAIRY" : preload("res://images_creatures/fairy_std.png"),
"FAIRY_PORTRAIT" : preload("res://images_creatures/creatr_portrt_fairy.png"),
"THIEF" : preload("res://images_creatures/thief_std.png"),
"THIEF_PORTRAIT" : preload("res://images_creatures/creatr_portrt_thief.png"),
"SAMURAI" : preload("res://images_creatures/samur_std.png"),
"SAMURAI_PORTRAIT" : preload("res://images_creatures/creatr_portrt_samur.png"),
"HORNY" : preload("res://images_creatures/hornd_std.png"),
"HORNY_PORTRAIT" : preload("res://images_creatures/creatr_portrt_horny.png"),
"SKELETON" : preload("res://images_creatures/skelt_std.png"),
"SKELETON_PORTRAIT" : preload("res://images_creatures/creatr_portrt_skelt.png"),
"TROLL" : preload("res://images_creatures/troll_std.png"),
"TROLL_PORTRAIT" : preload("res://images_creatures/creatr_portrt_troll.png"),
"DRAGON" : preload("res://images_creatures/dragn_std.png"),
"DRAGON_PORTRAIT" : preload("res://images_creatures/creatr_portrt_dragn.png"),
"DEMONSPAWN" : preload("res://images_creatures/dspwn_std.png"),
"DEMONSPAWN_PORTRAIT" : preload("res://images_creatures/creatr_portrt_spawn.png"),
"FLY" : preload("res://images_creatures/fly_std.png"),
"FLY_PORTRAIT" : preload("res://images_creatures/creatr_portrt_fly.png"),
"DARK_MISTRESS" : preload("res://images_creatures/dkmis_std.png"),
"DARK_MISTRESS_PORTRAIT" : preload("res://images_creatures/creatr_portrt_mistr.png"),
"SORCEROR" : preload("res://images_creatures/warlk_std.png"),
"SORCEROR_PORTRAIT" : preload("res://images_creatures/creatr_portrt_warlk.png"),
"BILE_DEMON" : preload("res://images_creatures/biled_std.png"),
"BILE_DEMON_PORTRAIT" : preload("res://images_creatures/creatr_portrt_biled.png"),
"IMP" : preload("res://images_creatures/imp_std.png"),
"IMP_PORTRAIT" : preload("res://images_creatures/creatr_portrt_imp.png"),
"BUG" : preload("res://images_creatures/bug_std.png"),
"BUG_PORTRAIT" : preload("res://images_creatures/creatr_portrt_bug.png"),
"VAMPIRE" : preload("res://images_creatures/vampr_std.png"),
"VAMPIRE_PORTRAIT" : preload("res://images_creatures/creatr_portrt_vampr.png"),
"SPIDER" : preload("res://images_creatures/spidr_std.png"),
"SPIDER_PORTRAIT" : preload("res://images_creatures/creatr_portrt_spidr.png"),
"HELL_HOUND" : preload("res://images_creatures/hound_std.png"),
"HELL_HOUND_PORTRAIT" : preload("res://images_creatures/creatr_portrt_hound.png"),
"GHOST" : preload("res://images_creatures/ghost_std.png"),
"GHOST_PORTRAIT" : preload("res://images_creatures/creatr_portrt_ghost.png"),
"TENTACLE" : preload("res://images_creatures/tentc_std.png"),
"TENTACLE_PORTRAIT" : preload("res://images_creatures/creatr_portrt_tentc.png"),
"ORC" : preload("res://images_creatures/orc_std.png"),
"ORC_PORTRAIT" : preload("res://images_creatures/creatr_portrt_orc.png"),
"FLOATING_SPIRIT" : preload("res://dk_images/magic_dust/anim0981/r1frame02.png"),
"FLOATING_SPIRIT_PORTRAIT" : preload("res://dk_images/magic_dust/anim0981/r1frame02.png"),
"DRUID" : preload("res://images_creatures/druid.png"),
"DRUID_PORTRAIT" : preload("res://images_creatures/druid_portrait.png"),
"TIME_MAGE" : preload("res://images_creatures/time_mage.png"),
"TIME_MAGE_PORTRAIT" : preload("res://images_creatures/time_mage_portrait.png"),
"MAIDEN" : preload("res://images_creatures/maiden.png"),
"MAIDEN_PORTRAIT" : preload("res://images_creatures/maiden_portrait.png"),
"SPIDERLING" : preload("res://images_creatures/spiderling.png"),
"SPIDERLING_PORTRAIT" : preload("res://images_creatures/spiderling_portrait.png"),
"BIRD" : preload("res://images_creatures/bird.png"),
"BIRD_PORTRAIT" : preload("res://images_creatures/bird_portrait.png"),
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

