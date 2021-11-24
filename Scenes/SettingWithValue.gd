extends HBoxContainer
tool # So that label text changes in editor
export var settingText = "SettingName" setget setLabel
export var minimumValue : float = 0
export var maximumValue : float = 0

onready var line = $LineEdit

func _ready():
	line.connect("focus_exited", self, "focus_exited")

func setLabel(newLabel):
	settingText = newLabel
	$Label.text = newLabel + ":"

func focus_exited():
	if minimumValue != 0 or maximumValue != 0:
		var numberValue = float(line.text)
		numberValue = clamp(numberValue, minimumValue, maximumValue)
		line.text = str(numberValue)
	
	var oSettingsWindow = Nodelist.list["oSettingsWindow"]
	oSettingsWindow.call("edited_"+name, line.text)

#	if "." in line.text:
#		numberValue = float(line.text)
#	else:
#		numberValue = int(line.text)
