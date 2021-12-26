extends VBoxContainer
class_name SpecialTabContainer
onready var oCustomTooltip = Nodelist.list["oCustomTooltip"]
onready var oTopTabsSection = $TopTabsSection
onready var tabFolder = $TabFolder
var tabSystem
var btnLeft
var btnRight

var current_tab setget set_current_tab,get_current_tab

var fullNameTabsWidth = 0

func _ready():
	
	tabSystem = oTopTabsSection.get_node("Tabs")
	
	btnLeft = oTopTabsSection.get_node("TextureButtonLeft")
	btnRight = oTopTabsSection.get_node("TextureButtonRight")
	
	tabSystem.connect("reposition_active_tab_request", self, "_on_Tabs_reposition_active_tab_request")
	tabSystem.connect("tab_changed", self, "_on_Tabs_tab_changed")
	tabSystem.connect("resized", self, "_on_Tabs_resized")
	tabSystem.connect("tab_hover", self, "_on_tab_hover")
	tabSystem.connect("mouse_exited", self, "_on_mouse_exited")
	tabSystem.connect("gui_input", self, "_on_gui_input")
	btnLeft.connect("pressed", self, "_on_TextureButtonLeft_pressed")
	btnRight.connect("pressed", self, "_on_TextureButtonRight_pressed")
	
	tabSystem.rect_min_size.y = 24
	
	tabSystem.add_stylebox_override("tab_bg",preload('res://Theme/thin_tab_bg.tres'))

func initialize(tabNameArray):
	
	for controlID in tabFolder.get_children():
		var idx = controlID.get_index()
		
		var setName
		if tabNameArray.empty() == false:
			setName = tabNameArray[idx]
		else:
			setName = controlID.name
		controlID.set_meta("tab_name", setName)
		tabSystem.add_tab(" ")
	
	set_icons()
	
	yield(get_tree(),'idle_frame')
	fullNameTabsWidth = 32 # needs a little extra to work correctly
	for i in get_tab_count():
		fullNameTabsWidth += tabSystem.get_tab_rect(i).size.x
	
	calculate_tab_title_width()
	
	set_current_tab(0)

func set_icons():
	
	var values = get_parent().tabs.values()
	for tabIndex in get_tab_count():
		
		var img = Image.new()
		var iconPath = values[tabIndex][get_parent().ICON_PATH]
		
		if iconPath == "": iconPath = 'res://Art/Thing.png'
		img = load(iconPath).get_data()
		
		img = img.get_rect(img.get_used_rect())
		
		if img.get_height() > img.get_width():
			var aspectRatioW = float(img.get_width()) / float(img.get_height())
			img.resize(31*aspectRatioW, 31)
		else:
			var aspectRatioH = float(img.get_height()) / float(img.get_width())
			img.resize(31, 31*aspectRatioH)
		
		var imgTex = ImageTexture.new()
		imgTex.create_from_image(img, 0)
		
		tabSystem.set_tab_icon(tabIndex, imgTex)


func set_current_tab(tab):
	tabSystem.current_tab = tab
	
	for i in tabFolder.get_children():
		var idx = i.get_index()
		if idx == get_current_tab():
			i.visible = true
			tabSystem.set_tab_title(idx, i.get_meta("tab_name"))
		else:
			tabSystem.set_tab_title(idx, " ")
			i.visible = false
	
	for i in 2:
		yield(get_tree(),'idle_frame')
		tabSystem.ensure_tab_visible(tab)

func _on_Tabs_reposition_active_tab_request(idx_to):
	move_child(tabFolder.get_child(tabSystem.current_tab), idx_to)


func _on_Tabs_tab_changed(tab):
	oCustomTooltip.set_text("")
	set_current_tab(tab)
	calculate_tab_title_width()


func _on_Tabs_resized():
	if get_tab_count() == 0: return # Fixes an error when initializing
	#tabSystem.disconnect("resized",self,"_on_Tabs_resized")
	set_current_tab(tabSystem.current_tab)
	yield(get_tree(),'idle_frame') # Stops arrow from going off frame for a split second
	calculate_tab_title_width()
	
	#tabSystem.connect("resized",self,"_on_Tabs_resized")


func calculate_tab_title_width():
	var tabsFit
	#if tabSystem.rect_size.x < fullNameTabsWidth:
	if tabSystem.get_offset_buttons_visible() == true:
		tabsFit = false
	else:
		tabsFit = true
	
	
	btnLeft.visible = !tabsFit
	btnRight.visible = !tabsFit
	
#	var childNodes = tabFolder.get_children()
#	for i in get_tab_count():
#		var fullName = childNodes[i].get_meta("tab_name")
#		if tabsFit == true:
#			tabSystem.set_tab_title(i, fullName)
#		else:
#			if i != get_current_tab():
#				tabSystem.set_tab_title(i, "")
#		else:
#			if i != get_current_tab():
#				tabSystem.set_tab_title(i, fullName.left(3))


func _on_TextureButtonLeft_pressed():
	var gotoTab = get_current_tab()-1
	if gotoTab <= -1:
		gotoTab = get_tab_count()-1
	set_current_tab(gotoTab)

func _on_TextureButtonRight_pressed():
	var gotoTab = get_current_tab()+1
	if gotoTab >= get_tab_count():
		gotoTab = 0
	set_current_tab(gotoTab)

# Replicating TabContainer functions below

func set_tab_title(tab, newName):
	tabSystem.set_tab_title(tab, newName)

func get_current_tab_control():
	return tabFolder.get_child(tabSystem.current_tab)

func get_tab_count():
	return tabSystem.get_tab_count()

func get_tab_control(index):
	return tabFolder.get_child(index)

func get_current_tab():
	return tabSystem.current_tab

func _on_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_WHEEL_UP:
			_on_TextureButtonRight_pressed()
		if event.button_index == BUTTON_WHEEL_DOWN:
			_on_TextureButtonLeft_pressed()


# Show and hide tab name depending on mouse cursor hover
func _on_tab_hover(hoveredTab):
	tabSystem.ensure_tab_visible(hoveredTab) # Scroll when hovering over hidden tab on the side
	
	var txt = ""
	for i in tabFolder.get_children():
		var idx = i.get_index()
		if idx == hoveredTab and idx != get_current_tab():
			txt = i.get_meta("tab_name")
	
	oCustomTooltip.set_text(txt)
	
#	for i in tabFolder.get_children():
#		var idx = i.get_index()
#		if idx == get_current_tab() or idx == hoveredTab:
#			tabSystem.set_tab_title(idx, i.get_meta("tab_name"))
#		else:
#			tabSystem.set_tab_title(idx, " ")
	calculate_tab_title_width()

func _on_mouse_exited():
	oCustomTooltip.set_text("")
	
	for i in tabFolder.get_children():
		var idx = i.get_index()
		if idx == get_current_tab():
			tabSystem.set_tab_title(idx, i.get_meta("tab_name"))
		else:
			tabSystem.set_tab_title(idx, " ")

	calculate_tab_title_width()
	tabSystem.ensure_tab_visible(get_current_tab())
