extends Node
onready var oReadData = Nodelist.list["oReadData"]
onready var oDataLof = Nodelist.list["oDataLof"]
onready var oBuffers = Nodelist.list["oBuffers"]

const DKLEVELS_NAMES = {
	"00001": "Eversmile",
	"00002": "Cosyton",
	"00003": "Waterdream Warm",
	"00004": "Flowerhat",
	"00005": "Lushmeadow-on-Down",
	"00006": "Snuggledell",
	"00007": "Wishvale",
	"00008": "Tickle",
	"00009": "Moonbrush Wood",
	"00010": "Nevergrim",
	"00011": "Hearth",
	"00012": "Elf's Dance",
	"00013": "Buffy Oak",
	"00014": "Sleepiburgh",
	"00015": "Woodly Rhyme",
	"00016": "TulipScent",
	"00017": "Mirthshire",
	"00018": "Blaise End",
	"00019": "Mistle",
	"00020": "Skybird Trill",
	"00050": "Multiplayer 1",
	"00051": "Multiplayer 2",
	"00052": "Multiplayer 3",
	"00053": "Multiplayer 4",
	"00054": "Multiplayer 5",
	"00055": "River sides",
	"00056": "Lava surround",
	"00057": "Heroes await",
	"00058": "Spaghetti",
	"00059": "The N map",
	"00060": "Multiplayer 6",
	"00061": "Multiplayer 7",
	"00062": "Multiplayer 8",
	"00063": "Multiplayer 9",
	"00064": "Multiplayer 10",
	"00065": "Ring of fire",
	"00066": "Lava forever",
	"00067": "Four Warlocks",
	"00068": "Cosy corners",
	"00069": "Unfair one",
	"00070": "Multiplayer 11",
	"00071": "Multiplayer 12",
	"00072": "Multiplayer 13",
	"00073": "Multiplayer 14",
	"00074": "Multiplayer 15",
	"00075": "Rotator",
	"00076": "Central arena",
	"00077": "Water around",
	"00078": "Your own special",
	"00079": "Blitzkrieg",
	"00100": "Secret 1",
	"00101": "Secret 2",
	"00102": "Secret 3",
	"00103": "Secret 4",
	"00104": "Secret 5",
	"00105": "Secret 6",
	"00122": "DD Multi 1",
	"00123": "DD Multi 2",
	"00124": "DD Multi 3",
	"00126": "DD Multi 4",
	"00127": "DD Multi 5",
	"00130": "DD Multi 6",
	"00131": "DD Multi 7",
	"00132": "DD Multi 8",
	"00133": "DD Multi 9",
	"00135": "DD Multi 10",
	"00145": "DD Multi 11",
	"00146": "DD Multi 12",
	"00147": "DD Multi 13",
	"00149": "DD Multi 14",
	"00150": "DD Multi 15",
}

const DDISK1_NAMES = {
	"00080": "Morkardar",
	"00081": "Korros Tor",
	"00082": "Kari-Mar",
	"00083": "Belbata",
	"00084": "Caddis Fell",
	"00085": "Pladitz",
	"00086": "Abbadon",
	"00087": "Svatona",
	"00088": "Kanasko",
	"00091": "Netzcaro",
	"00092": "Belial",
	"00093": "Batezek",
	"00094": "Benetzaron",
	"00095": "Daka-Gorn",
	"00097": "Dixaroc",
}

var data = ""

func set_map_name(mapStringName):
	data = mapStringName
	oDataLof.NAME_TEXT = mapStringName

func _ready():
	clear()

func clear():
	var dateDictionary = OS.get_date()
	
	var constructString = "Unnamed "
	constructString += str(dateDictionary["year"])+'.'+str(dateDictionary["month"])+'.'+str(dateDictionary["day"])
	constructString += " map"
	
	data = constructString
	oDataLof.NAME_TEXT = data


func lif_name_text(pathString):
	var buffer = oBuffers.file_path_to_buffer(pathString)
	var array = oReadData.lif_buffer_to_array(buffer)
	var mapName = oReadData.lif_array_to_map_name(array)
	return mapName


func get_special_lif_text(pathString): # Uses the path only as a string rather than reading it as a file
	var PATH_UPPERCASE = pathString.to_upper()
	# No lif name found, so check the built-in campaign map names.
	var specialNames = {}
	if "KEEPORIG" in PATH_UPPERCASE or "ORIGPLUS" in PATH_UPPERCASE:
		specialNames = DKLEVELS_NAMES
	elif "DEEPDNGN" in PATH_UPPERCASE:
		specialNames = DDISK1_NAMES

	var mapNumber = PATH_UPPERCASE.get_file().get_basename().trim_prefix("MAP")
	return specialNames.get(mapNumber, "")
