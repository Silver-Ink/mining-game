extends CanvasLayer
@onready var custom_cursor: Sprite2D = %CustomCursor

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _process(_delta: float) -> void:
	custom_cursor.global_position = custom_cursor.get_global_mouse_position()
	
func set_icon(icon : Texture2D)-> void:
	custom_cursor.texture = icon
