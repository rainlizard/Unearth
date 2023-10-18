extends Node2D
onready var oSelection = Nodelist.list["oSelection"]
onready var oInstanceOwnership = Nodelist.list["oInstanceOwnership"]
onready var oInspector = Nodelist.list["oInspector"]
onready var oInstances = Nodelist.list["oInstances"]
onready var oThingDetails = Nodelist.list["oThingDetails"]
onready var oPickThingWindow = Nodelist.list["oPickThingWindow"]

#onready var oSelection = $'../../Selector/Selection'
#onready var oInstanceOwnership = $'../../OverheadOwnership/InstanceOwnership'

var locationX = null setget set_location_x
var locationY = null setget set_location_y
var locationZ = null setget set_location_z
var thingType = null
var subtype = null
var ownership = null setget set_ownership

var effectRange = null setget set_effectRange
var sensitiveTile = null setget set_sensitiveTile
var doorOrientation = null setget set_doorOrientation
var creatureLevel = null setget set_creatureLevel
var doorLocked = null setget set_doorLocked
var herogateNumber = null setget set_herogateNumber
var boxNumber = null setget set_boxNumber
var index = null setget set_index

var data9 = null
var data10 = null
var data11_12 = null
var data13 = null
var data14 = null
var data15 = null
var data16 = null
var data17 = null
var data18 = null
var data19 = null
var data20 = null

var baseZindex = 0

# FX extended fields. Default initial values, important for when loading an old classic format map then switching it to KFX format in Map Settings.
var creatureGold = null
var creatureInitialHealth = null
var creatureName = null setget set_creatureName
var orientation = null
var goldValue = null

func _enter_tree():
	set_texture_based_on_thingtype()
	set_grow_direction()
	
	if sensitiveTile != null:
		add_to_group('attachedtotile_'+str(sensitiveTile))
	
	load_default_kfx_values()
	
	match thingType:
		Things.TYPE.TRAP:
			add_to_group("Trap")
		Things.TYPE.DOOR:
			add_to_group("Door")
		Things.TYPE.OBJECT:
			add_to_group("Object")
			if subtype == 44: # Spinning Key
				add_to_group("Key")
				# Display keys above door objects
				baseZindex = 2
				z_index = 2
			elif subtype in [52,53,54,55,56]:
				add_to_group("TreasuryGold")
			elif subtype in Things.LIST_OF_SPELLBOOKS:
				add_to_group("Spellbook")
		Things.TYPE.CREATURE:
			add_to_group("Creature")
			var oCamera2D = Nodelist.list["oCamera2D"]
			oCamera2D.connect("zoom_level_changed",self,"_on_zoom_level_changed")
			_on_zoom_level_changed(oCamera2D.zoom)
		Things.TYPE.EFFECTGEN:
			add_to_group("EffectGen")


func load_default_kfx_values():
	match thingType:
		Things.TYPE.OBJECT:
			if orientation == null or orientation == -1:
				orientation = 0
			if subtype in Things.LIST_OF_GOLDPILES:
				if goldValue == null or goldValue == -1:
					match subtype:
						3: goldValue = 500
						6: goldValue = 250
						43: goldValue = 200
						128: goldValue = 1
						136: goldValue = 100
		
		Things.TYPE.CREATURE:
			if creatureName == null:
				creatureName = ""
			if creatureInitialHealth == null or creatureInitialHealth == -1:
				creatureInitialHealth = 100
			if creatureGold == null or creatureGold == -1:
				creatureGold = 0
			if orientation == null or orientation == -1:
				orientation = 0
		Things.TYPE.EFFECTGEN:
			if orientation == null or orientation == -1:
				orientation = 0
		Things.TYPE.TRAP:
			if orientation == null or orientation == -1:
				orientation = 0
		Things.TYPE.DOOR:
			pass


func _exit_tree():
	# If a key is removed (manually deleted or otherwise) then change the door's lock state
	# This is good to put here to handle symmetry
	if subtype == 44 and thingType == Things.TYPE.OBJECT and is_in_group("Key"):
		var doorID = oInstances.get_node_on_subtile(locationX, locationY, "Door")
		if is_instance_valid(doorID) == true:
			doorID.doorLocked = 0


func set_location_x(setVal):
	if locationX != null and locationY != null:
		remove_from_group("slab_location_group_" + str(floor(locationX/3)) + '_' + str(floor(locationY/3)))
	locationX = setVal
	position.x = locationX * 32
	if locationX != null and locationY != null:
		add_to_group("slab_location_group_" + str(floor(locationX/3)) + '_' + str(floor(locationY/3)))

func set_location_y(setVal):
	if locationX != null and locationY != null:
		remove_from_group("slab_location_group_" + str(floor(locationX/3)) + '_' + str(floor(locationY/3)))
	locationY = setVal
	position.y = locationY * 32
	if locationX != null and locationY != null:
		add_to_group("slab_location_group_" + str(floor(locationX/3)) + '_' + str(floor(locationY/3)))


func set_location_z(setVal):
	locationZ = setVal


func _on_zoom_level_changed(zoom):
	var oUi = Nodelist.list["oUi"]
	var oQuickMapPreview = Nodelist.list["oQuickMapPreview"]
	var inventScale = Vector2()
	inventScale.x = clamp(zoom.x, 1.0, oUi.FONT_SIZE_CR_LVL_MAX)
	inventScale.y = clamp(zoom.y, 1.0, oUi.FONT_SIZE_CR_LVL_MAX)
	if zoom.x > oUi.FONT_SIZE_CR_LVL_MAX or oQuickMapPreview.visible == true:
		$ThingTexture/CreatureLevel.self_modulate = Color(0,0,0,0)
	else:
		$ThingTexture/CreatureLevel.self_modulate = Color(1,1,1,1)
	
	$ThingTexture/CreatureLevel.scale = inventScale * oUi.FONT_SIZE_CR_LVL_BASE

func set_ownership(setval):
	ownership = setval
	
	if ownership == 5 and thingType != Things.TYPE.CREATURE: # If the object has no ownership don't apply the material or else it'll flash.
		$ThingTexture.material = null
	else:
		if ownership == 255:
			print('For some reason ownership 255 at '+str(locationX)+' - '+str(locationY))
			return
			
		$ThingTexture.material = Nodelist.list["oInstanceOwnership"].materialInstanceOwnership[ownership]

func set_effectRange(setval):
	data9 = null
	data10 = null
	effectRange = setval
	update()

func set_index(setval):
	data11_12 = null
	index = setval

func set_sensitiveTile(setval):
	data11_12 = null
	sensitiveTile = setval
func set_doorOrientation(setval):
	data13 = null
	doorOrientation = setval
func set_creatureLevel(setval):
	data14 = null
	creatureLevel = setval
	$ThingTexture/CreatureLevel.frame = creatureLevel-1
	$ThingTexture/CreatureLevel.visible = true

func set_boxNumber(setval):
	data14 = null
	boxNumber = setval

func set_doorLocked(setval):
	data14 = null
	doorLocked = setval

func set_creatureName(setval):
	#setval = Utils.strip_special_chars_from_string(setval)
	creatureName = setval

func set_herogateNumber(setval):
	data14 = null
	herogateNumber = setval
	$GateNumber.text = str(herogateNumber)

func set_texture_based_on_thingtype():
	var tex = null
	match thingType:
		Things.TYPE.NONE:
			pass
		Things.TYPE.OBJECT:
			if Things.DATA_OBJECT.has(subtype) == true:
				
				tex = Things.DATA_OBJECT[subtype][Things.TEXTURE]
				
				if subtype in [49, 111,120,121,122]: # Heart Flame and Gate
					$ThingTexture.self_modulate = "a0ffffff"
				elif Things.LIST_OF_BOXES.has(subtype):
					$ThingTexture.rect_position += Vector2(-1,9)
					Nodelist.list["oPickThingWindow"].add_workshop_item_sprite_overlay($ThingTexture, subtype)
		Things.TYPE.CREATURE:
			if Things.DATA_CREATURE.has(subtype) == true:
				tex = Things.DATA_CREATURE[subtype][Things.TEXTURE]
				if tex != null:
					#$ThingTexture.rect_position.y -= 12
					$ThingTexture.rect_scale = Vector2(1.5,1.5)
		Things.TYPE.EFFECTGEN:
			if Things.DATA_EFFECTGEN.has(subtype) == true:
				tex = Things.DATA_EFFECTGEN[subtype][Things.TEXTURE]
		Things.TYPE.TRAP:
			if Things.DATA_TRAP.has(subtype) == true:
				tex = Things.DATA_TRAP[subtype][Things.TEXTURE]
		Things.TYPE.DOOR:
			if Things.DATA_DOOR.has(subtype) == true:
				tex = Things.DATA_DOOR[subtype][Things.TEXTURE]
	if tex != null:
		$ThingTexture.texture = tex
	else:
		$ThingTexture.texture = preload('res://Art/Thing.png')
		$ThingTexture.expand = true
		$ThingTexture.rect_scale = Vector2(0.5,0.5)
		$TextNameLabel.visible = true
		yield(get_tree(),'idle_frame')
		match thingType:
			Things.TYPE.OBJECT:
				if Things.DATA_OBJECT.has(subtype):
					$TextNameLabel.text = Things.DATA_OBJECT[subtype][Things.NAME]
			Things.TYPE.CREATURE:
				if Things.DATA_CREATURE.has(subtype):
					$TextNameLabel.text = Things.DATA_CREATURE[subtype][Things.NAME]
			Things.TYPE.EFFECTGEN:
				if Things.DATA_EFFECTGEN.has(subtype):
					$TextNameLabel.text = Things.DATA_EFFECTGEN[subtype][Things.NAME]
			Things.TYPE.TRAP:
				if Things.DATA_TRAP.has(subtype):
					$TextNameLabel.text = Things.DATA_TRAP[subtype][Things.NAME]
			Things.TYPE.DOOR:
				if Things.DATA_DOOR.has(subtype):
					$TextNameLabel.text = Things.DATA_DOOR[subtype][Things.NAME]
			Things.TYPE.EXTRA:
				if Things.DATA_EXTRA.has(subtype):
					$TextNameLabel.text = Things.DATA_EXTRA[subtype][Things.NAME]
		if " " in $TextNameLabel.text:
			$TextNameLabel.text = $TextNameLabel.text.replace(" ", "\n")
			$TextNameLabel.grow_vertical = Control.GROW_DIRECTION_BOTH
		else:
			$TextNameLabel.grow_vertical = Control.GROW_DIRECTION_END



func set_grow_direction():
	# Change Grow Direction so the art pokes out from the base.
	var texpath = $ThingTexture.texture.get_path()
	if "trapdoor_64" in texpath or "keepower_64" in texpath or "room_64" in texpath:
		pass
	else:
		$ThingTexture.grow_vertical = Control.GROW_DIRECTION_BEGIN

func _on_MouseDetection_mouse_entered():
	if oSelection.cursorOnInstancesArray.has(self) == false:
		oSelection.cursorOnInstancesArray.append(self)
	
	oSelection.clean_up_cursor_array()
	oThingDetails.update_details()
	update()
	$TextNameLabel.modulate = Color(1,1,1,1)
	z_index = baseZindex+1

func _on_MouseDetection_mouse_exited():
	if oSelection.cursorOnInstancesArray.has(self):
		oSelection.cursorOnInstancesArray.erase(self)
	oSelection.clean_up_cursor_array()
	oThingDetails.update_details()
	update()
	$TextNameLabel.modulate = Color(1,1,1,0.5)
	z_index = baseZindex

func instance_was_selected(): update()
func instance_was_deselected(): update()
func _draw():
	if effectRange != null and (oSelection.cursorOnInstancesArray.has(self) or oInspector.inspectingInstance == self):
		draw_arc(Vector2(0,0), (effectRange * 32)+16, 0, PI*2, 64, Color(0.75,1,0.75,1), 4, false)


func update_spinning_key(): # Called after changing the lock state
	# Get any overlapping key if one exists
	oInstances = Nodelist.list["oInstances"]
	var keyID = oInstances.get_node_on_subtile(locationX, locationY, "Key")
	
	if doorLocked == 0:
		# Door is unlocked
		if is_instance_valid(keyID) == true:
			# There's a key, so remove it
			keyID.queue_free()
	else:
		# Door is locked
		if is_instance_valid(keyID) == false:
			# There's no key, so create one
			oInstances.place_new_thing(Things.TYPE.OBJECT, 44, Vector3(locationX,locationY,locationZ-1), ownership)
		else:
			# There is a key, so update its ownership to match the lock's
			keyID.ownership = ownership

func _on_VisibilityNotifier2D_screen_entered():
	visible = true

func _on_VisibilityNotifier2D_screen_exited():
	visible = false

#func print_key_data():
#	print("data9 : " + str(data9))
#	print("data10 : " + str(data10))
#	print("data11_12 : " + str(data11_12))
#	print("data13 : " + str(data13))
#	print("data14 : " + str(data14))
#	print("data15 : " + str(data15))
#	print("data16 : " + str(data16))
#	print("data17 : " + str(data17))
#	print("data18 : " + str(data18))
#	print("data19 : " + str(data19))
#	print("data20 : " + str(data20))
#	print("locationX : " + str(locationX))
#	print("locationY : " + str(locationY))
#	print("locationZ : " + str(locationZ))
#	print("thingType : " + str(thingType))
#	print("subtype : " + str(subtype))
#	print("ownership : " + str(ownership))
#	print("effectRange : " + str(effectRange))
#	print("sensitiveTile : " + str(sensitiveTile))
#	print("doorOrientation : " + str(doorOrientation))
#	print("creatureLevel : " + str(creatureLevel))
#	print("doorLocked : " + str(doorLocked))
#	print("herogateNumber : " + str(herogateNumber))
#	print("boxNumber : " + str(boxNumber))
#	print("index : " + str(index))

#
#
#
#onready var oCreatureTextureRect = $'CreatureTextureRect'
#onready var oCreatureLevel = $'CreatureTextureRect/CreatureLevel'
#onready var oSelector = $'../../Selector'

#func _ready():
#	oCreatureTextureRect.visible = false
#	$ThingTexture.visible = true
#
#	match get_type():
#		TYPE.NONE: pass
#		TYPE.ITEM:
#			var tex = DATA_OBJECT[get_subtype()][TEXTURE]
#			if tex != null: $ThingTexture.texture = tex
#		TYPE.CREATURE:
#			$ThingTexture.visible = false
#			oCreatureTextureRect.visible = true
#			oCreatureTextureRect.texture = DATA_CREATURE[get_subtype()][TEXTURE]
#			oCreatureTextureRect.material = oInstanceOwnership.materialInstanceOwnership[get_ownership()]
#			oCreatureLevel.frame = data[CREATURE_LEVEL]
#		TYPE.EFFECT:
#			var tex = DATA_EFFECTGEN[get_subtype()][TEXTURE]
#			if tex != null: $ThingTexture.texture = tex
#		TYPE.TRAP:
#			var tex = DATA_TRAP[get_subtype()][TEXTURE]
#			if tex != null: $ThingTexture.texture = tex
#		TYPE.DOOR:
#			var tex = DATA_DOOR[get_subtype()][TEXTURE]
#			if tex != null: $ThingTexture.texture = tex
#
#	if $ThingTexture.texture == null:
#		$ThingTexture.modulate = col
#
#func setOwnership():
#	var value = data[OWNERSHIP]
#	if value == 5:
#		col = Color.cyan # White
#	else:
#		col = Constants.ownerRoomCol[value]
#
#func setPosition():
#	position.x = data[SUBTILE_X] * SUBTILE_SIZE
#	position.y = data[SUBTILE_Y] * SUBTILE_SIZE
#	position.x += (data[SUBTILE_X_WITHIN] / 256.0) * SUBTILE_SIZE
#	position.y += (data[SUBTILE_Y_WITHIN] / 256.0) * SUBTILE_SIZE
#	altitude = data[SUBTILE_Z] * SUBTILE_SIZE
#	altitude += (data[SUBTILE_Z_WITHIN] / 256.0) * SUBTILE_SIZE
#
