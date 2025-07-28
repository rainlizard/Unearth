extends Label

func _ready():
	visible = false #default

func _on_Wait_timeout():
	var fps = Engine.get_frames_per_second()
	var textLine1 = str(fps)+' FPS'
	var textLine2 = str(1000*(Performance.get_monitor(Performance.TIME_PROCESS)))+"ms" #frame time
	text = textLine1+'\n'+textLine2

func _notification(what): # Hide FPS counter while it goes crazy when alt-tabbing back in
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		if visible == true and Settings.get_setting("pause_when_minimized") == true:
			visible = false
			yield(get_tree().create_timer(2.5), "timeout")
			visible = true
