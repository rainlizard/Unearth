extends Node
onready var oConfirmReloadTXT = Nodelist.list["oConfirmReloadTXT"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oEasyScriptWindow = Nodelist.list["oEasyScriptWindow"]

var data = ""

func _ready():
	check_modified_loop()

func check_modified_loop():
	if oCurrentMap.currentFilePaths.has("TXT"):
		var filePath = oCurrentMap.currentFilePaths["TXT"][oCurrentMap.PATHSTRING]
		var getModifiedTime = File.new().get_modified_time(filePath)
		if oCurrentMap.currentFilePaths["TXT"][oCurrentMap.MODIFIED_DATE] != getModifiedTime:
			if oConfirmReloadTXT.visible == false:
				Utils.popup_centered(oConfirmReloadTXT)
				
				# Only need to show it once. Prevent from popping up again by setting the modified date
				oCurrentMap.currentFilePaths["TXT"][oCurrentMap.MODIFIED_DATE] = getModifiedTime

	yield(get_tree().create_timer(1.0), "timeout")
	check_modified_loop()


func _on_ConfirmReloadTXT_confirmed():
	if oCurrentMap.currentFilePaths.has("TXT"):
		var filePath = oCurrentMap.currentFilePaths["TXT"][oCurrentMap.PATHSTRING]
		Filetypes.read(filePath, "TXT")
		oEasyScriptWindow.reload_script_into_window()
