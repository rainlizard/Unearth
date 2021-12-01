tool
extends EditorPlugin

var scriptExportPlugin = preload("res://addons/IncludeOnExport/export.gd").new()

func _enter_tree():
	print('EditorExportPlugin activated.')
	add_export_plugin(scriptExportPlugin)

func _exit_tree():
	remove_export_plugin(scriptExportPlugin)
