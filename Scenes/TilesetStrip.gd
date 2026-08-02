extends Control

signal tile_selected(index)

onready var oCustomTooltip = Nodelist.list["oCustomTooltip"]

const COLUMNS = 8
const ROWS = 68
const TILE_SIZE = 32

var imageTexture: ImageTexture
var selectedIndex = 0
var hoveredIndex = -1
var textureIdOffset = 0
var zoom = 1


func set_image(image: Image):
	imageTexture = ImageTexture.new()
	imageTexture.create_from_image(image, 0)
	update()


func set_zoom(value: int):
	zoom = value
	rect_min_size = Vector2(COLUMNS * TILE_SIZE, ROWS * TILE_SIZE) * zoom
	update()


func set_selected(index: int):
	selectedIndex = index
	update()


func _draw():
	if imageTexture == null: return
	var displaySize = Vector2(COLUMNS * TILE_SIZE, ROWS * TILE_SIZE) * zoom
	draw_texture_rect(imageTexture, Rect2(Vector2.ZERO, displaySize), false)
	var gridColor = Color(1, 1, 1, 0.18)
	for x in COLUMNS + 1:
		draw_line(Vector2(x * TILE_SIZE * zoom, 0), Vector2(x * TILE_SIZE * zoom, displaySize.y), gridColor)
	for y in ROWS + 1:
		draw_line(Vector2(0, y * TILE_SIZE * zoom), Vector2(displaySize.x, y * TILE_SIZE * zoom), gridColor)
	var tilePosition = Vector2(selectedIndex % COLUMNS, selectedIndex / COLUMNS) * TILE_SIZE * zoom
	draw_rect(Rect2(tilePosition, Vector2(TILE_SIZE, TILE_SIZE) * zoom), Color(0.7, 0.7, 0.7), false, 2)
	if hoveredIndex != -1:
		var hoverPosition = Vector2(hoveredIndex % COLUMNS, hoveredIndex / COLUMNS) * TILE_SIZE * zoom
		draw_rect(Rect2(hoverPosition, Vector2(TILE_SIZE, TILE_SIZE) * zoom), Color(1, 0.85, 0, 1), false, 2)


func _gui_input(event):
	var isMouseMotion = event is InputEventMouseMotion
	var isLeftClick = event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed
	if isMouseMotion == false and isLeftClick == false: return
	if Rect2(Vector2.ZERO, Vector2(COLUMNS, ROWS) * TILE_SIZE * zoom).has_point(event.position) == false:
		hoveredIndex = -1
		oCustomTooltip.set_text("")
		update()
		return
	var tilePosition = event.position / (TILE_SIZE * zoom)
	var index = int(tilePosition.y) * COLUMNS + int(tilePosition.x)
	if index < 0 or index >= COLUMNS * ROWS: return
	if isMouseMotion:
		hoveredIndex = index
		oCustomTooltip.set_text(str(textureIdOffset + index))
		update()
	if (isLeftClick or Input.is_mouse_button_pressed(BUTTON_LEFT)) and (index != selectedIndex or isLeftClick):
		selectedIndex = index
		emit_signal("tile_selected", index)
		update()


func _on_mouse_exited():
	hoveredIndex = -1
	oCustomTooltip.set_text("")
	update()
