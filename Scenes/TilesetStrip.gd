extends Control

signal tile_selected(index)

onready var oCustomTooltip = Nodelist.list["oCustomTooltip"]
onready var oReadPalette = Nodelist.list["oReadPalette"]

const COLUMNS = 8
const ROWS = 68
const TILE_SIZE = 32
const STRIP_SHADER = preload("res://Shaders/tileset_strip.shader")

var imageTexture: ImageTexture
var selectedIndex = 0
var hoveredIndex = -1
var textureIdOffset = 0
var zoom = 1
var shaderMaterial: ShaderMaterial


func _ready():
	shaderMaterial = ShaderMaterial.new()
	shaderMaterial.shader = STRIP_SHADER
	material = shaderMaterial


func set_image(image: Image):
	imageTexture = ImageTexture.new()
	imageTexture.create_from_image(image, 0)
	shaderMaterial.set_shader_param("palette_texture", oReadPalette.palette_image_texture_2d)
	update()


func set_zoom(value: int):
	zoom = value
	shaderMaterial.set_shader_param("zoom", float(zoom))
	rect_min_size = Vector2(COLUMNS * TILE_SIZE, ROWS * TILE_SIZE) * zoom
	update()


func set_selected(index: int):
	selectedIndex = index
	update()


func _draw():
	if imageTexture == null: return
	var displaySize = Vector2(COLUMNS * TILE_SIZE, ROWS * TILE_SIZE) * zoom
	shaderMaterial.set_shader_param("hovered_index", hoveredIndex)
	draw_texture_rect(imageTexture, Rect2(Vector2.ZERO, displaySize), false)


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
