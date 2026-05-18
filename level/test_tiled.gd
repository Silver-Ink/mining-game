extends Node2D

@onready var shapes : ShapeManager = ShapeManager.new()
const SPRITE_BACKGROUND = preload("uid://cn7250215l36p")
@onready var camera: Camera2D = $camera

func _ready() -> void:
	add_child(shapes)
	_generate(Vector2i(16,9))
	_camera_focus()
	get_tree().root.connect("size_changed", _camera_focus)
	
func _camera_focus():
	var game_bounding_box = Rect2(shapes.bounding_box())
	
	game_bounding_box.position *= ShapeSprite.TILE_SIZE
	game_bounding_box.position -= Vector2(ShapeSprite.TILE_SIZE / 2., ShapeSprite.TILE_SIZE / 2.)
	game_bounding_box.size *= ShapeSprite.TILE_SIZE
	
	# Calculate required zoom to fit bounding box
	var viewport_size = get_viewport().get_visible_rect().size
	var zoom = viewport_size / game_bounding_box.size
	var min_zoom = min(zoom.x, zoom.y) * 0.9
	zoom = Vector2(min_zoom,min_zoom)
	
	camera.zoom = zoom
	camera.position = game_bounding_box.get_center()
	
func _on_window_resized():
	# Use call_deferred to avoid layout issues
	call_deferred("_camera_focus")

	
func _generate(size: Vector2i):
	shapes.clear()
	
	#var bg = BACKGROUND.instantiate()
	var shape = Shape.new();
	shape.tile = Tiles.new().add_rect(Rect2i(0,0,size.x,size.y));
	shape.sprite = SPRITE_BACKGROUND.instantiate()
	shapes.insert(shape)
	#shape.move(Vector2i(3,5))


func _process(delta: float) -> void:
	pass
