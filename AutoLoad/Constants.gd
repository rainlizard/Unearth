extends Node
const VERSION = "0.31b"
const unearth_map_format_version:float = 1.00

const TILE_SIZE = 96
const SUBTILE_SIZE = 32

const ownerFloorCol = [Color8(132,44,0,255), Color8(136,112,148,255), Color8(52,92,4,255), Color8(188,156,0,255), Color8(207,207,207,255), Color8(52,36,4,255)] #Color8(180,160,124,255)
const ownerRoomCol = [Color8(156,48,0,255), Color8(160,136,180,255), Color8(56,112,12,255), Color8(228,212,0,255), Color8(242,242,242,255), Color8(0,0,0,0)] #Color8(188,168,132,255)
const ownershipNames = ["Red","Blue","Green","Yellow","White","None"]

enum {
	READ = 0
	WRITE = 1
}

const TEXTURE_MAP_NAMES = {
0: "Standard",
1: "Ancient",
2: "Winter",
3: "Snake Key",
4: "Stone Face",
5: "Voluptuous", #"Big Breasts"
6: "Rough Ancient",
7: "Skull Relief",
8: "Desert Tomb",
9: "Gypsum",
10: "Lilac Stone",
11: "Swamp Serpent",
12: "Lava Cavern",
}
