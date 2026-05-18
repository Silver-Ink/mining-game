extends Node2D
class_name ShapeManager 

var _bounding_box : Rect2i = Rect2i();
var _list : Array[Shape] = [];

# Dictionary[Vector2i, Array[Shape]]
var lookup: Dictionary[Vector2i, Array] = {} 

func insert(tiled : Shape):
	tiled.map = self

	_list.append(tiled)

	for t in tiled.tiles():
		var array = lookup.get_or_add(t, [])
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
		var array = lookup.get(pos)
		if array:
			array.erase(tiled)
		if array.is_empty():
			lookup.erase(pos)
			
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
	var result: Array[Shape] = lookup.get(pos, [])
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
		lookup.clear()
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
		var array = lookup.get(pos)
		if array != null:
			array.erase(tiled)
			if array.is_empty():
				lookup.erase(pos)

	tiled.tile.move_all(delta)

	for pos in tiled.tiles():
		var array = lookup.get(pos)
		if array == null:
			array = []
			lookup[pos] = array
		array.append(tiled)
		
	tiled.on_tiles_changed()
	_recompute_bounding_box()
