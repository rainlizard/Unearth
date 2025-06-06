extends Node

onready var oExportTmapDatDialog = Nodelist.list["oExportTmapDatDialog"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oTeditLiveReloadPNG = Nodelist.list["oTeditLiveReloadPNG"]

var originalDatDir = ""
var originalDatPath = ""
var originalDatFilename = ""


func start_dat_export():
	Utils.popup_centered(oExportTmapDatDialog)
	oExportTmapDatDialog.current_dir = originalDatDir
	oExportTmapDatDialog.current_path = originalDatPath
	oExportTmapDatDialog.current_file = originalDatFilename


func set_original_dat_info(filename: String, datDir: String, datPath: String):
	originalDatFilename = filename
	originalDatDir = datDir
	originalDatPath = datPath


func _on_ExportTmapDatDialog_file_selected(pathArgument: String):
	if oTeditLiveReloadPNG.editingImg.is_empty() or oTeditLiveReloadPNG.editingImg.get_format() != Image.FORMAT_L8:
		oMessage.big("Error", "Cannot export. Internal image is not in L8 format or is empty.")
		return
	var file = File.new()
	if file.open(pathArgument, File.WRITE) == OK:
		file.store_buffer(oTeditLiveReloadPNG.editingImg.get_data())
		file.close()
		oMessage.quick("Exported : " + pathArgument.get_file())
	else:
		oMessage.big("Error", "Failed to open file for writing: " + pathArgument) 
