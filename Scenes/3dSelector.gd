extends Spatial
#
#onready var oRayCastBlockMap = Nodelist.list["oRayCastBlockMap"]
#onready var oPlayer = Nodelist.list["oPlayer"]
#onready var oCamera3D = Nodelist.list["oCamera3D"]
#onready var oColumnDetails = Nodelist.list["oColumnDetails"]
#onready var oGame3D = Nodelist.list["oGame3D"]
#onready var oGenerateTerrain = Nodelist.list["oGenerateTerrain"]
#onready var oSelectorMesh3D = Nodelist.list["oSelectorMesh3D"]
#onready var oDataClm = Nodelist.list["oDataClm"]
#onready var oDataClmPos = Nodelist.list["oDataClmPos"]
#onready var oFloor = Nodelist.list["oFloor"]
#onready var oLoadingBar = Nodelist.list["oLoadingBar"]
#
#var reach = 100
#var previousTranslation = Vector3()

#func _process(delta):
#	visible = false
#	#if oColumnDetails.visible == false: return #Only display Selector3D if "view column details" is visible
#	if oLoadingBar.visible == true: return
#	if oGame3D.materialArray.size() == 0: return
#	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and oGenerateTerrain.GENERATED_TYPE == oGenerateTerrain.GEN_MAP: return
#
#	var startPoint = oCamera3D.global_transform.origin
#	var endPoint = startPoint + (oPlayer.oHead.global_transform.basis.z.normalized() * reach)
#
#	var collisionResult = oRayCastBlockMap.start(startPoint, endPoint)
#
#	if collisionResult:
#		visible = true
#		previousTranslation = translation
#
#		if collisionResult.collider == oFloor:
#			translation = collisionResult.position.floor()
#
#			if collisionResult.normal.y < 0.9:
#				visible = false
#		else:
#			translation = collisionResult.collider.translation
#
#		if translation != previousTranslation:
#			oColumnDetails.update_details()
#			resize()
#
#		translation.y = 0
#	else:
#		visible = false
#
#	if translation.x < 0: visible = false
#	if translation.y < 0: visible = false
#	if translation.z < 0: visible = false
#	if translation.x >= oGenerateTerrain.TERRAIN_SIZE_X: visible = false
#	if translation.y >= oGenerateTerrain.TERRAIN_SIZE_Y: visible = false
#	if translation.z >= oGenerateTerrain.TERRAIN_SIZE_Z: visible = false
#
#
#func resize():
#	var clmIndex
#	var newSize
#	if oGenerateTerrain.GENERATED_TYPE == oGenerateTerrain.GEN_MAP:
#		clmIndex = oDataClmPos.get_cell(translation.x,translation.z)
#	elif oGenerateTerrain.GENERATED_TYPE == oGenerateTerrain.GEN_CLM:
#		clmIndex = oGenerateTerrain.get_clm_index(translation.x,translation.z)
#
#	if clmIndex != null:
#		newSize = oDataClm.get_height_from_bottom(clmIndex)
#	else:
#		newSize = 0
#
#	if newSize == 0:
#		newSize = 0.1
#
#	oSelectorMesh3D.mesh.size.y = newSize
#	oSelectorMesh3D.translation.y = oSelectorMesh3D.mesh.size.y * 0.5
