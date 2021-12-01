extends MenuButton
tool
onready var scriptIconTexture = get_icon("Script", "EditorIcons")
var popup = get_popup()

func add_singletons(dictionary, plugin, currentlyOpen, alphasort:bool):
	var dictionaryKeys:Array = dictionary.keys()
	var dictionaryValues:Array# = dictionary.values()
	
	if alphasort:
		dictionaryKeys.sort()

	for i in dictionaryKeys.size():
		dictionaryValues.append(dictionary[dictionaryKeys[i]])
	
	for i in dictionary.size():
		popup.add_item(dictionaryKeys[i])
		popup.set_item_metadata(i, dictionaryValues[i])
		popup.set_item_icon(i, scriptIconTexture)
		
		if dictionaryValues[i] == currentlyOpen:
			popup.set_item_disabled(i,true)
