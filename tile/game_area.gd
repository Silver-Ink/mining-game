extends Node2D
class_name GameArea 

var _bounding_box : Rect2i = Rect2i();
var _list : Array[Shape] = [];

# Dictionary[Vector2i, Array[Shape]]
var _lookup: Dictionary[Vector2i, Array] = {}

var layout : GameAreaLayout = null

var game : Game = null:
	get:
		return game
	set(value):
		assert(game == null)
		assert(value != null)
		game = value

func insert(tiled : Shape):
	tiled.area = self

	_list.append(tiled)

	for t in tiled.tiles():
		var array = _lookup.get_or_add(t, [])
		array.append(tiled)
		
	add_child(tiled)
	tiled.on_tiles_changed()

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
	var result: Array[Shape] = _lookup.get(pos, [])
	result.sort_custom(func(a, b): return a.level < b.level)
	return result.duplicate()

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

func update_camera(camera: Camera2D, viewport: Viewport):
	assert(viewport)
	var game_bounding_box = Rect2(self.bounding_box())
	
	game_bounding_box.position *= ShapeSprite.TILE_SIZE
	game_bounding_box.position -= Vector2(ShapeSprite.TILE_SIZE / 2., ShapeSprite.TILE_SIZE / 2.)
	game_bounding_box.size *= ShapeSprite.TILE_SIZE
	
	# Calculate required zoom to fit bounding box
	var viewport_size = viewport.get_visible_rect().size
	var zoom = viewport_size / game_bounding_box.size
	var min_zoom = min(zoom.x, zoom.y) * 0.9
	zoom = Vector2(min_zoom,min_zoom)
	
	camera.zoom = zoom
	camera.position = game_bounding_box.get_center()
	

func enter():
	pass
	
func leave():
	pass

func _generate():
	self.clear()
	
	var bg = Shape.new();
	bg.tile = Tiles.new().add_rect(Rect2i(0,0,layout.size.x,layout.size.y))
	bg.sprite = Assets.sprite_rock_background
	bg.area = self;
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
