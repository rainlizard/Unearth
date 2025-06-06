extends WindowDialog

onready var oMessage = Nodelist.list["oMessage"]
onready var oExportTmapButton = Nodelist.list["oExportTmapButton"]
onready var oReloaderPathPackLabel = Nodelist.list["oReloaderPathPackLabel"]
onready var oTEScrollContainer = Nodelist.list["oTEScrollContainer"]
onready var oTeditLoadDAT = Nodelist.list["oTeditLoadDAT"]
onready var oTeditSavePNG = Nodelist.list["oTeditSavePNG"]
onready var oTeditLiveReloadPNG = Nodelist.list["oTeditLiveReloadPNG"]
onready var oTeditSaveDAT = Nodelist.list["oTeditSaveDAT"]

var _dialog_confirmed = false


func _ready():
	oExportTmapButton.disabled = true
	oExportTmapButton.set_tooltip("A filelist pack must be loaded first in order to export")
	oReloaderPathPackLabel.text = ""


func _on_TextureEditingHelpButton_pressed():
	var helptxt = """After you load a tileset, a bunch of .PNG files will be saved to your hard drive, edit these files in your favourite image editor.
Unearth will actively reload the textures in real-time as you edit and save those .PNGs. So any edits you make will be shown in real-time in Unearth. This applies to the 3D view too, you can press Spacebar while in the 3D view to stop the camera from moving."""
	oMessage.big("Help", helptxt)


func _on_CreateFilelistButton_pressed():
	oTeditLoadDAT.start_file_selection()


func _on_ModifyTexturesButton_pressed():
	oTeditSavePNG.open_texture_folder()


func _on_ExportTmapButton_pressed():
	oTeditSaveDAT.start_dat_export()


func enable_export_button():
	oExportTmapButton.disabled = false
	oExportTmapButton.set_tooltip("")


func disable_export_button():
	oExportTmapButton.disabled = true
	oExportTmapButton.set_tooltip("A filelist pack must be loaded first in order to export")


func update_reloader_path_label(path: String):
	oReloaderPathPackLabel.text = path
	yield(get_tree(),'idle_frame')
	oTEScrollContainer.scroll_horizontal = 1000000


func show_confirmation_dialog(message: String) -> bool:
	var confirmDialog = ConfirmationDialog.new()
	confirmDialog.dialog_text = message
	confirmDialog.window_title = "Confirm File Replacement"
	confirmDialog.popup_exclusive = true
	add_child(confirmDialog)
	_dialog_confirmed = false
	confirmDialog.connect("confirmed", self, "_on_dialog_confirmed")
	confirmDialog.popup_centered()
	yield(confirmDialog, "popup_hide")
	yield(get_tree(), "idle_frame")
	var userConfirmed = _dialog_confirmed
	confirmDialog.queue_free()
	return userConfirmed


func _on_dialog_confirmed():
	_dialog_confirmed = true

