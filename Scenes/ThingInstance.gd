extends Node2D
onready var oSelection = Nodelist.list["oSelection"]
onready var oInstanceOwnership = Nodelist.list["oInstanceOwnership"]
onready var oInspector = Nodelist.list["oInspector"]
onready var oInstances = Nodelist.list["oInstances"]

#onready var oSelection = $'../../Selector/Selection'
#onready var oInstanceOwnership = $'../../OverheadOwnership/InstanceOwnership'

var locationX = null
var locationY = null
var locationZ = null
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

var data9 = null
var data10 = null
var data11 = null
var data12 = null
var data13 = null
var data14 = null
var data15 = null
var data16 = null
var data17 = null
var data18 = null
var data19 = null
var data20 = null

func _enter_tree():
	position.x = locationX * 32
	position.y = locationY * 32
	set_texture_based_on_thingtype()
	set_grow_direction()
	
	if sensitiveTile != null:
		add_to_group('attachedtotile_'+str(sensitiveTile))
	
	match thingType:
		Things.TYPE.DOOR:
			add_to_group("Door")
		Things.TYPE.OBJECT:
			if subtype == 44: # Spinning Key
				add_to_group("Key")
#			if subtype == 49:
#				var oCamera2D = Nodelist.list["oCamera2D"]
#				oCamera2D.connect("zoom_level_changed",self,"_on_zoom_level_changed")
#				_on_zoom_level_changed(oCamera2D.zoom)
		Things.TYPE.CREATURE:
			var oCamera2D = Nodelist.list["oCamera2D"]
			oCamera2D.connect("zoom_level_changed",self,"_on_zoom_level_changed")
			_on_zoom_level_changed(oCamera2D.zoom)

func _on_zoom_level_changed(zoom):
	var oUi = Nodelist.list["oUi"]
	var inventScale = Vector2()
	inventScale.x = clamp(zoom.x, 1.0, oUi.FONT_SIZE_CR_LVL_MAX)
	inventScale.y = clamp(zoom.y, 1.0, oUi.FONT_SIZE_CR_LVL_MAX)
	if zoom.x > oUi.FONT_SIZE_CR_LVL_MAX:
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

func set_sensitiveTile(setval):
	data11 = null
	data12 = null
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
			tex = Things.DATA_OBJECT[subtype][Things.TEXTURE]
			if subtype in [49, 111,120,121,122]: # Heart Flame and Gate
				$ThingTexture.self_modulate = "a0ffffff"
		Things.TYPE.CREATURE:
			if Things.DATA_CREATURE.has(subtype) == true:
				tex = Things.DATA_CREATURE[subtype][Things.TEXTURE]
				if tex != null:
					$ThingTexture.rect_position.y -= 12
					$ThingTexture.rect_scale = Vector2(1.75,1.75)
		Things.TYPE.EFFECT:
			if Things.DATA_EFFECT.has(subtype) == true:
				tex = Things.DATA_EFFECT[subtype][Things.TEXTURE]
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
	update()

func _on_MouseDetection_mouse_exited():
	if oSelection.cursorOnInstancesArray.has(self):
		oSelection.cursorOnInstancesArray.erase(self)
	oSelection.clean_up_cursor_array()
	update()

func instance_was_selected(): update()
func instance_was_deselected(): update()
func _draw():
	if effectRange != null and (oSelection.cursorOnInstancesArray.has(self) or oInspector.inspectingInstance == self):
		draw_arc(Vector2(0,0), (effectRange * 32)+16, 0, PI*2, 64, Color(0.75,1,0.75,1), 4, false)

func toggle_spinning_key(): # Called when you manually change the lock state
	# If door has no key, then create a key.
	# If door has key, then destroy the key.
	
	var keyID = oInstances.get_node_of_group_on_subtile("Key", locationX, locationY)
	if is_instance_valid(keyID) == true:
		if doorLocked == 0:
			keyID.queue_free()
	else:
		if doorLocked == 1:
			oInstances.place_new_thing(Things.TYPE.OBJECT, 44, Vector3(locationX,locationY,locationZ), ownership)

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
#			var tex = DATA_EFFECT[get_subtype()][TEXTURE]
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
#		col = Constants.ownershipColors[value]
#
#func setPosition():
#	position.x = data[SUBTILE_X] * SUBTILE_SIZE
#	position.y = data[SUBTILE_Y] * SUBTILE_SIZE
#	position.x += (data[SUBTILE_X_WITHIN] / 256.0) * SUBTILE_SIZE
#	position.y += (data[SUBTILE_Y_WITHIN] / 256.0) * SUBTILE_SIZE
#	altitude = data[SUBTILE_Z] * SUBTILE_SIZE
#	altitude += (data[SUBTILE_Z_WITHIN] / 256.0) * SUBTILE_SIZE
#
