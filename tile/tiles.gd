class_name Tiles # TileSet est déjà utilsé...
#extends Resource

var _tiles: Dictionary[Vector2i,bool]
var _bounding_box: Rect2i = Rect2i();

const VALUE = 1

# Inspired by https://www.reddit.com/r/godot/comments/1esljuk/elevate_your_godot_code_with_a_set_type/

# Begin of the Tile Trait / Interface, thank godot for supporting them

func add(element: Vector2i) -> Tiles:
	_add(element)
	_update_bounding_box()
	return self
	
func add_rect(rect: Rect2i) -> Tiles:
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			_add(Vector2i(x, y))
	_update_bounding_box()
	return self

func add_all(elements: Array[Vector2i]) -> Tiles:
	for element in elements:
		_add(element)
	_update_bounding_box()
	return self

func merge(other: Tiles) -> Tiles:
	add_all(other.tiles())
	return self

func remove(element):
	_remove(element)
	_update_bounding_box()

func remove_all(elements):
	for element in elements:
		_remove(element)
	_update_bounding_box()

func contains(element) -> bool:
	return _tiles.has(element)

func tiles() -> Array[Vector2i]:
	return _tiles.keys().duplicate()

func clear():
	_tiles.clear()
	_bounding_box = Rect2i()

func is_empty():
	return _tiles.is_empty()

func size():
	return _tiles.size()

func bounding_box() -> Rect2i:
	return _bounding_box
	
func move_all(delta: Vector2i):
	if delta == Vector2i.ZERO:
		return
	
	var old_tiles = _tiles.duplicate()
	_tiles.clear()
	
	for pos in old_tiles.keys():
		_tiles[pos + delta] = VALUE
	
	_bounding_box.position += delta

func _update_bounding_box() -> void:
	if _tiles.is_empty():
		_bounding_box = Rect2i()
		return
	
	var min_x: int = 0
	var min_y: int = 0
	var max_x: int = 0
	var max_y: int = 0
	var first: bool = true
	
	for pos in _tiles.keys():
		if first:
			min_x = pos.x
			min_y = pos.y
			max_x = pos.x
			max_y = pos.y
			first = false
		else:
			min_x = min(min_x, pos.x)
			min_y = min(min_y, pos.y)
			max_x = max(max_x, pos.x)
			max_y = max(max_y, pos.y)
	
	_bounding_box = Rect2i(Vector2i(min_x, min_y), Vector2i(max_x - min_x + 1, max_y - min_y + 1))
	
	
# End of the Tiled Trait
	
func _init():
	_tiles = {}

func _add(element: Vector2i):
	_tiles[element] = VALUE
	
func _remove(element):
	_tiles.erase(element)
