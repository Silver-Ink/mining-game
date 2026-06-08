@icon("res://assets/icons/shape_icon.svg")
extends Node2D
class_name Shape

var _tiles: Dictionary[Vector2i,Tile] = {}
var _bounding_box: Rect2i = Rect2i();

# I miss my Rust `Option<Asset<Audio>>` type
### When a tile inside the shape is digged
var sfx_dig : String = &""
## When the shape is fully visible
var sfx_visibility_gain_total   : String = &""
## When the shape is revealed a bit more, but not fully
var sfx_visibility_gain_partial : String = &""
## When the shape lose some visibility (either total or partial)
var sfx_visibility_lose : String = &""
## When destroyed because it is frage
var sfx_fragile_break : String = &""

#region Trait Tiled. Thank godot for not supporting them...
func on_tile_added():
	self.on_tile_changed()
	
func on_tile_removed():
	self.on_tile_changed()
	if self.is_fragile:
		if area:
			self.area.sfx.play(self.sfx_fragile_break);
		self.clear_tile()
		
func _add_tile(pos: Vector2i, tile: Tile) -> Shape:
	self._tiles[pos] = tile
	_update_bounding_box() # O(n), can be O(1) but whatever
	if self.area:
		self.area._shape_add_tile(self, pos)
	return self

func _remove_tile(pos: Vector2i) -> Tile:
	if self._tiles.get(pos):
		var value = self._tiles.get(pos)
		self._tiles.erase(pos)
		_update_bounding_box()
		if self.area:
			self.area._shape_remove_tile(self, pos)
		return value
	return null

func get_tile(pos: Vector2i) -> Tile:
	return self._tiles.get(pos, null)
	
func contains_tile(pos: Vector2i) -> bool:
	return self._tiles.has(pos)

func tiles() -> Array[Vector2i]:
	return self._tiles.keys().duplicate()
	
func bounding_box() -> Rect2i:
	return self._bounding_box
	
func move_all_tile(delta: Vector2i):
	if delta == Vector2i.ZERO:
		return
	
	for pos in self._tiles:
		self._remove_tile(pos)
		
	var old_tiles = _tiles
	_tiles = {}
	
	for pos in old_tiles:
		self._add_tile(pos + delta, old_tiles[pos])
	
	self.render_node.position += Vector2(delta) * ShapeSprite.ZOOM;

#region Default impl
func add_tile(pos: Vector2i, tile: Tile) -> Shape:
	self._add_tile(pos, tile)
	self.on_tile_added()
	return self
	
func add_tile_rect(rect: Rect2i, tile: Tile) -> Shape:
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			self._add_tile(Vector2i(x, y), tile.duplicate())
	self.on_tile_added()
	return self

func add_all_tile(elements: Array[Vector2i], tile: Tile) -> Shape:
	for pos in elements:
		self._add_tile(pos, tile.duplicate())
	self.on_tile_added()
	return self

func merge_tile(other: Dictionary[Vector2i,Tile]) -> Shape:
	for e in other:
		self._add_tile(e, other[e].duplicate())
	self.on_tile_added()
	return self

func remove_tile(element: Vector2i) -> Tile:
	var removed = _remove_tile(element)
	if removed:
		self.on_tile_removed()
	return removed

func remove_all_tile(elements: Array[Vector2i]) -> Dictionary[Vector2i, Tile]:
	var removed = Dictionary()
	for pos in elements:
		var remove = _remove_tile(pos)
		if remove:
			removed[pos] = remove
	if !removed.is_empty():
		self.on_tile_removed()
	return removed


func nb_tile() -> int:
	return self.tiles().size()

func clear_tile():
	var any_cleared = false
	for t in self.tiles():
		self._remove_tile(t)
		any_cleared = true
	if  any_cleared:
		self.on_tile_removed()

func is_tile_empty():
	return self.nb_tile() <= 0
#endregion

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
	
#endregion End of the Tiled Trait

#region Shape properties
## Is concerned by the action of digging
@export var absorb_dig: bool = true

## Per Shape for the moment. Can be moved per _tile if needed YAGNI :)
@export var is_destructible: bool = true

## destroying 1 tile = destroying all tiles
@export var is_fragile: bool = false

var nb_tile_visible : int = 0:
	get:
		return nb_tile_visible
	set(value):
		if nb_tile_visible == value:
			return
		var old_value = nb_tile_visible
		nb_tile_visible = value
					
		if area:
			if nb_tile_visible > old_value:
				if nb_tile_visible == nb_tile():
					area.sfx.play(self.sfx_visibility_gain_total)
				else:
					area.sfx.play(self.sfx_visibility_gain_partial)
			else:
				area.sfx.play(self.sfx_visibility_lose)
		
		if self.is_treasure():
			for node in render_node.get_children():
				if node is Sprite2D:
					if is_collected():
						#node.modulate = Color.DIM_GRAY
						var tween = create_tween()
						tween.tween_property(node, "modulate", Color(2, 2, 2, 1), 0.1)
						tween.tween_property(node, "modulate", Color.DIM_GRAY, 0.3)
					else:
						node.modulate = Color.WHITE
		
		#print("tile visible: " + str(nb_tile_visible) + " / " + str(nb_tile()) + " = " + str(coef_tile_visible() * 100.) + " %")

#var _tile: Tiles = Tiles.new():
	#get:
		#return _tile
	#set(value):
		#if area:
			#area.remove(self)
		#_tile = value
		#if area:
			#area.insert(self)

# Z level
@export var height : int = 0:
	get:
		return height
	set(value):
		height = value
		

var area: GameArea = null:
	get:
		return area
	set(value):
		if area == value:
			return
		if area != null:
			var m = area;
			area = null;
			m.remove(self)
		
		area = value
		if value != null:
			value.insert(self)

var render_node: Node2D = Node2D.new()

var sprite: ShapeSprite = ShapeSprite.new():
	get:
		return sprite
	set(value):
		sprite = value
		assert(render_node != null)
		sprite.update_render(self, render_node)
		
var shape_name: GE.ShapeName = GE.ShapeName.Unknow;
#endregion

func is_treasure() -> bool:
	return shape_name != GE.ShapeName.Unknow

func is_collected() -> bool:
	return self.nb_tile_visible == self.nb_tile() && self.is_treasure()
	
func coef_tile_visible() -> float:
	var nb_tile = nb_tile()
	if nb_tile != 0:
		return nb_tile_visible as float / nb_tile() as float
	return 0.

#@export var _tile: Tiles = Tiles.new():



func with_area(area: GameArea) -> Shape:
	self.area = area
	return self

	
func on_tile_changed():
	self.sprite.update_render(self, render_node)
	


func _ready() -> void:
	add_child(self.render_node)


func preset_tileset_rock() -> Shape:
	self.sprite = ShapeSprite.ROCK
	self.is_destructible = true
	self.absorb_dig = true
	return self.preset_layer_foreground()
	
func preset_tileset_background() -> Shape:
	self.sprite = ShapeSprite.WALL
	self.is_destructible = false
	self.absorb_dig = false
	return self.preset_layer_background()
	
func preset_tileset_bone() -> Shape:
	self.sprite = ShapeSprite.BONE
	self.is_destructible = true
	self.is_fragile = true
	self.sfx_fragile_break = &"bone_break";
	self.absorb_dig = true
	return self.preset_layer_treasure()

func preset_treasure_bracelet() -> Shape:
	self.sprite = ShapeSprite.BRACELET
	self.add_all_tile(
		[
			# Un petit côté Alain D.
			Vector2i(-1,-1), Vector2i(0,-1), Vector2i(1,-1),
			Vector2i(-1, 0)                , Vector2i(1, 0),
			Vector2i(-1, 1), Vector2i(0,1) , Vector2i(1, 1),
		], Tile.new())
	return self.preset_treasure(GE.ShapeName.Bracelet)

func preset_treasure(name : GE.ShapeName, offset = 0) -> Shape:
	self.preset_layer_treasure(offset)
	self.is_destructible = false
	self.absorb_dig = true
	self.is_fragile = false
	self.shape_name = name
	self.sfx_visibility_gain_partial = "treasure_reveal_partial"
	self.sfx_visibility_gain_total = "treasure_reveal_total"
	self.sfx_visibility_lose = "treasure_unreveal"
	return self
	


func preset_layer(layer: GE.Layer, offset = 0) -> Shape:
	self.height = layer + offset
	return self

func preset_layer_background(offset = 0) -> Shape:
	return self.preset_layer(GE.Layer.BACKGROUND, offset)
	
func preset_layer_treasure(offset = 0) -> Shape:
	return self.preset_layer(GE.Layer.TREASURE, offset)

func preset_layer_foreground(offset = 0) -> Shape:
	return self.preset_layer(GE.Layer.FOREGROUND, offset)
