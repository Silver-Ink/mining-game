extends Node2D
class_name GameArea 

var _bounding_box : Rect2i = Rect2i();
var _list : Array[Shape] = [];

# Of type Dictionary[Vector2i, Array[Shape]]
var _lookup: Dictionary[Vector2i, Array] = {}

# Dictionary[Vector2i, Array[Shape]]

var layout : GameAreaLayout = null

var game : Game = null:
	get:
		return game
	set(value):
		assert(game == null)
		assert(value != null)
		game = value

func insert(tiled : Shape):
	assert(tiled)
	tiled.area = self
	_list.append(tiled)

	for t in tiled.tiles():
		var array = _lookup.get_or_add(t, [])
		array.append(tiled)
	
	tiled.z_index = tiled.height
	add_child(tiled)
	tiled.on_tile_changed()

	_update_bounding_box(tiled)

func remove(tiled : Shape):
	if tiled.map != self:
		return

	tiled.map = null
	_list.erase(tiled)

	for pos in tiled.tiles():
		var array = _lookup.get(pos)
		if array:
			array.erase(tiled)
		if array.is_empty():
			_lookup.erase(pos)
			
	remove_child(tiled)
	tiled.on_tiles_changed()

	_recompute_bounding_box()

func _recompute_bounding_box() -> void:
	if _list.is_empty():
		_bounding_box = Rect2i()
		return

	_bounding_box = _list[0].bounding_box()
	for i in range(1, _list.size()):
		var rect = _list[i].bounding_box()
		var new_min = Vector2i(
			min(_bounding_box.position.x, rect.position.x),
			min(_bounding_box.position.y, rect.position.y)
		)
		var new_max = Vector2i(
			max(_bounding_box.end.x, rect.end.x),
			max(_bounding_box.end.y, rect.end.y)
		)
		_bounding_box = Rect2i(new_min, new_max - new_min)


func get_at(pos: Vector2i) -> Array[Shape]:
	var result: Array = _lookup.get(pos, [])
	

	var typed_result: Array[Shape] = []	
	typed_result.assign(result)

	typed_result.sort_custom(func(a: Shape, b: Shape): return a.height > b.height)
	return typed_result

func get_all() -> Array[Shape]:
	return _list.duplicate()

func bounding_box() -> Rect2i:
	return _bounding_box

func is_empty() -> bool:
	return _list.is_empty()

func clear() -> void:
	for tiled in _list:
		tiled.map = null
		_list.clear()
		_lookup.clear()
		_bounding_box = Rect2i()

func contains(tiled : Shape) -> bool:
	return tiled.map == self

func _update_bounding_box(tiled: Shape) -> void:
	if _list.size() == 1:
		_bounding_box = tiled.bounding_box()
		return

	var new_rect = tiled.bounding_box()
	var new_min = Vector2i(
	min(_bounding_box.position.x, new_rect.position.x),
	min(_bounding_box.position.y, new_rect.position.y)
	)
	var new_max = Vector2i(
		max(_bounding_box.end.x, new_rect.end.x),
		max(_bounding_box.end.y, new_rect.end.y)
	)
	_bounding_box = Rect2i(new_min, new_max - new_min)

func move(tiled: Shape, delta: Vector2i):
	assert(contains(tiled))

	if delta == Vector2i.ZERO:
		return

	for pos in tiled.tiles():
		var array = _lookup.get(pos)
		if array != null:
			array.erase(tiled)
			if array.is_empty():
				_lookup.erase(pos)

	tiled.tile.move_all(delta)

	for pos in tiled.tiles():
		var array = _lookup.get(pos)
		if array == null:
			array = []
			_lookup[pos] = array
		array.append(tiled)
		
	tiled.on_tiles_changed()
	_recompute_bounding_box()
	
	
	
	
func _init(layout : GameAreaLayout) -> void:
	assert(layout != null)
	self.layout = layout

func _ready() -> void:
	_generate()

func bounding_box_px() -> Rect2:
	var game_bounding_box = Rect2(self.bounding_box())
	game_bounding_box.position *= ShapeSprite.SIZE
	game_bounding_box.size *= ShapeSprite.SIZE
	game_bounding_box.position -= Vector2(ShapeSprite.SIZE / 2., ShapeSprite.SIZE / 2.)
	return game_bounding_box

func update_camera(camera: Camera2D, viewport: Viewport):
	assert(viewport)

	var bounding_box = bounding_box_px()
	
	# Calculate required zoom to fit bounding box
	var viewport_size = viewport.get_visible_rect().size
	var zoom = viewport_size / bounding_box.size
	var min_zoom = min(zoom.x, zoom.y) * 0.9
	zoom = Vector2(min_zoom,min_zoom)
	camera.zoom = zoom
	camera.position = bounding_box.get_center()
	
func mouse_tile_pos() -> Vector2i:
	var viewport = get_viewport()
	var camera = viewport.get_camera_2d()
	if not camera:
		assert(false) # Invalid position
		return Vector2i.ZERO  
	
	# Get the game bounding box in world coordinates (same as update_camera)
	var bounding_box = bounding_box_px()
	
	# Get mouse position in screen coordinates
	var mouse_screen_pos = viewport.get_mouse_position()
	var viewport_size = viewport.get_visible_rect().size
	
	# Convert to world coordinates using camera position and zoom
	var mouse_world_pos = camera.position + (mouse_screen_pos - viewport_size / 2) / camera.zoom
	
	# Clamp to game bounding box (optional)
	mouse_world_pos = mouse_world_pos.clamp(bounding_box.position, bounding_box.position + bounding_box.size)
	
	# Convert to tile coordinates
	var tile_pos = Vector2i(
		floor((mouse_world_pos.x + ShapeSprite.SIZE * 0.5) / ShapeSprite.SIZE),
		floor((mouse_world_pos.y + ShapeSprite.SIZE * 0.5) / ShapeSprite.SIZE)
	)
	
	return tile_pos

func enter():
	pass
	
func leave():
	pass
	
var was_left_mouse_pressed = false
	
func _process(delta: float) -> void:
	var pos : Vector2i = mouse_tile_pos()
	
	var is_left_mouse_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if  is_left_mouse_pressed and not was_left_mouse_pressed:
		self.use_tool(pos)
	was_left_mouse_pressed = is_left_mouse_pressed

func use_tool(pos):
	dig(pos)
	
func dig(pos) -> bool:
	for shape: Shape in self.get_at(pos):
		if shape.is_destructible:
			shape.remove(pos)
			return true
	return false

func _generate():
	self.clear()
	
	var bg : Shape = Shape.new();
	bg.add_rect(Rect2i(0,0,layout.size.x,layout.size.y))
	bg.preset_tileset_background()
	bg.area = self;
	
	var rock : Shape = Shape.new();
	rock.add_rect(Rect2i(0,0,layout.size.x,layout.size.y))
	rock.preset_tileset_rock()
	rock.area = self;
	
	var bone = Shape.new();
	bone.add_rect(Rect2i(layout.size.x / 2 - 1,layout.size.y / 2 - 1,3,3))
	bone.preset_tileset_bone()
	bone.area = self;
	
	Shape.new().preset_tileset_bracelet().with_area(self)
	
	#self.insert(bg)
	
	#var bg = BACKGROUND.instantiate()
	#var shape = Shape.new();
	#shape.tile = Tiles.new().add_rect(Rect2i(0,0,size.x,size.y));
	#shape.sprite = SPRITE_BACKGROUND.instantiate()
	#shapes.insert(shape)
	
	#var shape2 = Shape.new();
	#shape2.tile = Tiles.new().add_rect(Rect2i(0,0,size.x / 2,size.y / 2));
	#shape2.sprite = SPRITE_ROCK.instantiate()
	#shape2.level = 5
	#shapes.insert(shape2)
	#shape.move(Vector2i(3,5))
