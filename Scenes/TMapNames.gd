extends Node
onready var oTMapLoader = Nodelist.list["oTMapLoader"]
onready var oGame = Nodelist.list["oGame"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]

var texture_map_names = {}

func _ready():
	update_texture_map_names()

func update_texture_map_names():
	if oTMapLoader.rememberedTmapaPaths == null:
		return

	var tmapDataByNumber = {}
	for pathStr in oTMapLoader.rememberedTmapaPaths.keys():
		var parsedDetails = oTMapLoader.parse_tmap_path_details(pathStr)
		if parsedDetails != null and parsedDetails.type == "tmapa" and parsedDetails.number >= 0:
			var sourceType = "campaign"
			if pathStr.begins_with(oGame.DK_DATA_DIRECTORY):
				sourceType = "data"
			elif oCurrentMap.path != "" and pathStr.begins_with(oCurrentMap.path.get_base_dir()):
				sourceType = "map"
			tmapDataByNumber[parsedDetails.number] = {"path": pathStr, "source": sourceType, "filename": pathStr.get_file()}

	var default_texture_map_names = {
		0: "Standard", 1: "Ancient", 2: "Winter", 3: "Snake Key", 4: "Stone Face",
		5: "Voluptuous", 6: "Rough Ancient", 7: "Skull Relief", 8: "Desert Tomb",
		9: "Gypsum", 10: "Lilac Stone", 11: "Swamp Serpent", 12: "Lava Cavern",
		13: "Laterite Cavern"
	}
	
	var new_texture_map_names = {}
	var textureCount = 0
	if oTMapLoader.cachedTextures != null:
		if typeof(oTMapLoader.cachedTextures) == TYPE_ARRAY or typeof(oTMapLoader.cachedTextures) == TYPE_DICTIONARY:
			textureCount = oTMapLoader.cachedTextures.size()

	for i in range(textureCount):
		var itemText = default_texture_map_names.get(i, "Untitled")
		if tmapDataByNumber.has(i):
			var tmapInfo = tmapDataByNumber[i]
			var filename = tmapInfo.filename
			if tmapInfo.source == "data":
				itemText = default_texture_map_names.get(i, "/data/" + filename)
			else: # map source
				itemText = "/" + tmapInfo.path.get_base_dir().get_file() + "/" + filename
		new_texture_map_names[i] = itemText
	
	texture_map_names = new_texture_map_names
