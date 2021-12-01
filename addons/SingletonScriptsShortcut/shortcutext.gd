extends Button
tool

onready var scriptIconTexture = get_icon("Script", "EditorIcons")
onready var popup := $Popup
onready var checkbutton := $Popup/VBoxContainer/HBoxContainer/CheckButton
onready var itemlist := $Popup/VBoxContainer/ItemList

signal request_items(itemlist, sorted)

func _ready():
	connect("pressed", self, "show_popup")
	checkbutton.connect("toggled", self, "change_sort")

func show_popup():
	emit_signal("request_items", itemlist, checkbutton.pressed)
	var r = get_global_rect()
	r.position+=Vector2(0,64)
	popup.popup(r)

func change_sort(tog):
	emit_signal("request_items", itemlist, tog)

func add_singletons(dictionary, plugin, currentlyOpen, alphasort:bool=true):
	var dictionaryKeys:Array = dictionary.keys()
	var dictionaryValues:Array
	
	if alphasort:
		dictionaryKeys.sort()

	for i in dictionaryKeys.size():
		dictionaryValues.append(dictionary[dictionaryKeys[i]])
	
	for i in dictionary.size():
		itemlist.add_item(dictionaryKeys[i])
		itemlist.set_item_metadata(i, dictionaryValues[i])
		itemlist.set_item_icon(i, scriptIconTexture)
		
		if dictionaryValues[i] == currentlyOpen:
			itemlist.set_item_disabled(i,true)
	release_focus()
