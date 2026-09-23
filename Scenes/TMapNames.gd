extends Node
onready var oTMapLoader = Nodelist.list["oTMapLoader"]
onready var oGame = Nodelist.list["oGame"]

var texture_map_names = {}

const DEFAULT_TEXTURE_MAP_NAMES = {
	0: "Standard", 1: "Ancient", 2: "Winter", 3: "Snake Key", 4: "Stone Face",
	5: "Voluptuous", 6: "Rough Ancient", 7: "Skull Relief", 8: "Desert Tomb",
	9: "Gypsum", 10: "Lilac Stone", 11: "Swamp Serpent", 12: "Lava Cavern",
	13: "Laterite Cavern"
}

func _ready():
	update_texture_map_names()

func update_texture_map_names():
	if oTMapLoader.rememberedTmapaPaths == null:
		return
	var pathsByNumber = _get_tmap_paths_by_number()
	texture_map_names.clear()
	var textureCount = oTMapLoader.cachedTextures.size() if oTMapLoader.cachedTextures != null else 0
	for i in range(textureCount):
		var itemText = DEFAULT_TEXTURE_MAP_NAMES.get(i, "Untitled")
		if pathsByNumber.has(i):
			var path = pathsByNumber[i]
			itemText = DEFAULT_TEXTURE_MAP_NAMES.get(i, "/data/" + path.get_file()) if path.begins_with(oGame.DK_DATA_DIRECTORY) else "/" + path.get_base_dir().get_file() + "/" + path.get_file()
		texture_map_names[i] = itemText


func _get_tmap_paths_by_number() -> Dictionary:
	var paths = {}
	for path in oTMapLoader.rememberedTmapaPaths:
		var details = oTMapLoader.parse_tmap_path_details(path)
		if details != null and details.number >= 0 and (paths.has(details.number) == false or details.type == "tmapa"):
			paths[details.number] = path
	return paths


func get_tileset_name(number: int) -> String:
	var loadedName = texture_map_names.get(number, "")
	if loadedName.begins_with("/") and loadedName.begins_with("/data/") == false:
		return loadedName.get_file()
	return DEFAULT_TEXTURE_MAP_NAMES.get(number, "")
