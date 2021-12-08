extends LineEdit
class_name EditableLabel
tool # To auto-set the styles
const style = preload('res://Class/StyleEditableLabel.tres')

# Set "editable" to true or false to make this label editable or not

func _init():
	if Engine.editor_hint: # Code to execute when in editor.
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set("custom_styles/read_only", style)
		set("custom_styles/normal", style)
	
	connect("focus_exited",self,"_on_EditableLabel_focus_exited")

func _ready():
	text = text # Fixes a Godot bug where alignment is incorrect when handling custom fonts

func _on_EditableLabel_focus_exited():
	self.release_focus()
