class_name rock_tile extends Area2D

signal digged(tile : rock_tile)

const MAX_SURFACE_LEVEL := 5
const TILE_EDGE = 8
const SURFACE_LEVEL_ZORDER_GAP = 2

var id : int
var grid_pos : Vector2i
var excavate_area : ExcavateArea

var _is_mouse_hovered := false
var _surface_level := MAX_SURFACE_LEVEL

@onready var dig_preview: Sprite2D = %digPreview
@onready var rock_sprite: Sprite2D = %rockSprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	dig_preview.z_index = MAX_SURFACE_LEVEL * SURFACE_LEVEL_ZORDER_GAP + 1
	#set_surface_level(randi_range(0, MAX_SURFACE_LEVEL))
	set_surface_level(MAX_SURFACE_LEVEL)

func _unhandled_input(event: InputEvent) -> void:
	if (_is_mouse_hovered && event.is_action_pressed("use_tool")):
		ToolManager.use_tool(excavate_area, grid_pos)

func dig() -> void:
	if (set_surface_level(_surface_level - 1)):
		digged.emit(self)
	
func set_surface_level(level : int) -> bool:
	if (!clamp(level, 0, MAX_SURFACE_LEVEL) == level):
		return false
	rock_sprite.region_rect = Rect2(TILE_EDGE * (MAX_SURFACE_LEVEL - level)\
									, 0, 8, 8)
	rock_sprite.z_index = level * SURFACE_LEVEL_ZORDER_GAP
	_surface_level = level
	return true

func _on_mouse_entered() -> void:
	dig_preview.texture = ToolManager.get_tool_dig_preview()
	_is_mouse_hovered = true
	dig_preview.visible = true
	
func _on_mouse_exited() -> void:
	_is_mouse_hovered = false
	dig_preview.visible = false
