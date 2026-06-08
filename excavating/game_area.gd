extends Node2D
class_name GameArea 

# Todo: should be null and lazyly computed on demand to avoid O(n) and have O(1) complexity
var _bounding_box : Rect2i = Rect2i();
var _shapes : Array[Shape] = [];

# Of type Dictionary[Vector2i, Array[Shape]]
var _lookup: Dictionary[Vector2i, Array] = {}
#var _collected_treasure : Dictionary[Shape,bool] = {}

var is_generating : bool = true:
	get:
		return is_generating
	set(value):
		if is_generating == value:
			return
		is_generating = value
		#if !is_generating:
			#_collected_treasure.clear()
			#for shape in _shapes:
			#	shape.nb_tile_visible = shape.nb_tile_visible
			
	

func collected_treasure() -> Array[Shape]:
	var shapes : Array[Shape] = []
	for shape in _shapes:
		if shape.is_collected():
			shapes.append(shape)
	return shapes

# Dictionary[Vector2i, Array[Shape]]

var generator : GameAreaGenerator = null

var game : ExcavatingGame = null:
	get:
		return game
	set(value):
		assert(game == null)
		assert(value != null)
		game = value

var _sounds: Dictionary = {
	&"treasure_reveal_partial":&"678493__adamcreeper__hmmmm.wav",
	&"treasure_reveal_total":&"817813__el_boss__treasure-collected-coin-tinkle-game-sound-effect.wav",
	&"treasure_unreveal": &"160909__racche__scratch-speed.wav",
	
	&"rock_damage": &"654499__bigal13__pickaxe-striking-hard-rock.ogg",
	&"rock_dig":&"728759__techspiredminds__metallic-pickaxe-44.wav",

	&"leaf_damage": &"106130__j1987__leafpilehit.wav",
	&"leaf_dig": &"106130__j1987__leafpilehit.wav",

	&"hammer": &"420878__inspectorj__digging-ice-hammer-a.wav",
	
	&"sand":&"651292__f3bbbo__digging-in-wet-course-sand-1.wav",
	&"bone_break": &"188034__antumdeluge__bones-2.wav",

	&"done" : &"256113__nckn__done.wav",
}

var sfx : Audio = Audio.new()

	

## Sort the list of shape at a given position using their height and return the array
func _sort_at(pos: Vector2i) -> Array[Shape]:
	var typed_result: Array[Shape] = []
	typed_result.assign(self._lookup.get_or_add(pos, []))
	typed_result.sort_custom(func(a: Shape, b: Shape): return a.height > b.height)
	self._lookup[pos] = typed_result
	return typed_result

func insert(shape : Shape):
	assert(shape)
	shape.area = self
	_shapes.append(shape)
	
	shape.nb_tile_visible = 0

	for pos in shape.tiles():
		self._shape_add_tile(shape, pos)
	
	shape.z_index = shape.height
	add_child(shape)
	shape.on_tile_changed()
	_update_bounding_box()

func remove(tiled : Shape):
	if tiled.map != self:
		return

	tiled.map = null
	_shapes.erase(tiled)

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
	if _shapes.is_empty():
		_bounding_box = Rect2i()
		return

	_bounding_box = _shapes[0].bounding_box()
	for i in range(1, _shapes.size()):
		var rect = _shapes[i].bounding_box()
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
	var typed_result: Array[Shape] = []	
	typed_result.assign(_lookup.get(pos, []))
	return typed_result

func get_all() -> Array[Shape]:
	return _shapes.duplicate()

func bounding_box() -> Rect2i:
	return _bounding_box

func is_empty() -> bool:
	return _shapes.is_empty()


func _shape_add_tile(shape: Shape, pos: Vector2i):
	assert(shape.area == self)
	
	var typed_result: Array[Shape] = []	
	typed_result.assign(self._lookup.get_or_add(pos, []))

	if typed_result.find(shape) == -1:
		typed_result.append(shape)
		self._lookup[pos] = typed_result
		
		typed_result = _sort_at(pos)
		if typed_result[0] == shape:
			shape.nb_tile_visible += 1
			if typed_result.size() >= 2:
				typed_result[1].nb_tile_visible -= 1
	
	self._lookup[pos] = typed_result
	self._update_bounding_box()

func _shape_remove_tile(shape: Shape, pos: Vector2i):
	assert(shape.area == self)

	var typed_result: Array[Shape] = []	
	typed_result.assign(self._lookup.get_or_add(pos, []))
	
	if typed_result[0] == shape:
		shape.nb_tile_visible -= 1
		if typed_result.size() >= 2:
			typed_result[1].nb_tile_visible += 1
	typed_result.erase(shape)
	
	self._lookup[pos] = typed_result
	self._update_bounding_box()
	
	

func clear() -> void:
	for shape in _shapes:
		shape.map = null
		_shapes.clear()
		_lookup.clear()
		_bounding_box = Rect2i()

func contains(tiled : Shape) -> bool:
	return tiled.map == self

func _update_bounding_box() -> void:
	var first: bool = true
	
	for s in self._shapes:
		var bb: Rect2i = s.bounding_box()
		
		if first:
			_bounding_box = bb
			first = false
		else:
			_bounding_box = _bounding_box.merge(bb)

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
	
	
	
	
func _init(generator : GameAreaGenerator) -> void:
	assert(generator != null)
	self.generator = generator

func _ready() -> void:
	
	
	for key in _sounds:
		sfx.add_key(key, "res://assets/sfx/" + _sounds[key])
	add_child(sfx)

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



func use_tool(tool: GE.Tools, pos: Vector2i):
	match tool:
		GE.Tools.Pickaxe:
# .1.
# 121
# .1.
			dig(pos, 2)
			dig(pos + Vector2i.RIGHT, 1)
			dig(pos + Vector2i.LEFT, 1)
			dig(pos + Vector2i.UP, 1)
			dig(pos + Vector2i.DOWN, 1)
			pass
		GE.Tools.Hammer:
# 121
# 222
# 121
			dig(pos, 2)
			dig(pos + Vector2i.RIGHT, 2)
			dig(pos + Vector2i.LEFT, 2)
			dig(pos + Vector2i.UP, 2)
			dig(pos + Vector2i.DOWN, 2)
			
			dig(pos + Vector2i.RIGHT + Vector2i.UP, 1)
			dig(pos + Vector2i.LEFT + Vector2i.UP, 1)
			dig(pos + Vector2i.RIGHT + Vector2i.DOWN, 1)
			dig(pos + Vector2i.LEFT + Vector2i.DOWN, 1)
			pass
		_:
			assert(false, "Le todo du pauvre, à implémenter")



func dig(pos: Vector2i, force: int):
	for shape: Shape in self.get_at(pos):
		if shape.absorb_dig:
			if shape.is_destructible:
				var tile : Tile = shape.get_tile(pos)
				tile.hp -= force
				# FIXME: Will be called multiple time because tools digs multiple tile at once,
				# can use some kind of dirty flag + HashSet of shape to regenerate the render 
				if tile.hp <= 0:
					force = abs(tile.hp)
					shape.remove_tile(pos)
				else:
					force = 0
					self.sfx.play(shape.sfx_damage)
					shape.update_render() 
				
				if force <= 0:
					return
			return
	

func _generate():
	generator.generate_in(self)


func spawn_shape(kind: GE.ShapeName) -> Shape:
	var shape = _spawn_shape(kind)
	if shape:
		shape.with_area(self)
	return shape

func _spawn_shape(kind: GE.ShapeName) -> Shape:
	match kind:
		GE.ShapeName.Bracelet:
			return Shape.new().preset_treasure_bracelet()
		GE.ShapeName.BatTalisman:
			return Shape.new().preset_treasure_bat_talisman()
		GE.ShapeName.Boomerang:
			return Shape.new().preset_treasure_boomerang()
		GE.ShapeName.Diamound:
			# Spawn diamond treasure
			pass
		GE.ShapeName.Snake:
			# Spawn snake treasure
			pass
		GE.ShapeName.GluedStone:
			# Spawn glued stone treasure
			pass
		GE.ShapeName.HorshoeCrab:
			# Spawn horseshoe crab treasure
			pass
		GE.ShapeName.PeruKnife:
			# Spawn Peru knife treasure
			pass
		GE.ShapeName.RedGem:
			# Spawn red gem treasure
			pass
		GE.ShapeName.RomanRuler:
			# Spawn Roman ruler treasure
			pass
		GE.ShapeName.Ruby:
			# Spawn ruby treasure
			pass
		GE.ShapeName.Shell:
			# Spawn shell treasure
			pass
		GE.ShapeName.SkaraBrae:
			# Spawn Skara Brae treasure
			pass
		GE.ShapeName.SkullSaber:
			# Spawn skull saber treasure
			pass
		GE.ShapeName.TenonHead:
			# Spawn tenon head treasure
			pass
		GE.ShapeName.Trex:
			# Spawn T-Rex treasure
			pass

		GE.ShapeName.Bg:
			return Shape.new().preset_tileset_background()
		GE.ShapeName.Rock:
			return Shape.new().preset_tileset_rock()
		GE.ShapeName.Leaf:
			return Shape.new().preset_tileset_leaf()
		GE.ShapeName.Sand:
			return Shape.new().preset_tileset_sand()
		GE.ShapeName.Bone:
			return Shape.new().preset_tileset_bone()
		_:
			return null
	return null
	
	
