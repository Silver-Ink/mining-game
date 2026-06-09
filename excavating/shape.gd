@icon("res://assets/icons/shape_icon.svg")
extends Node2D
class_name Shape

var _tiles: Dictionary[Vector2i,Tile] = {}
var _bounding_box: Rect2i = Rect2i();
var _default_tile = Tile.new()

#region Sfx
# I miss my Rust `Option<Asset<Audio>>` type
## When a tile inside the shape is digged
var sfx_dig : String = &""

## When a tile is damaged
var sfx_damage : String = &""

## When the shape is fully visible
var sfx_visibility_gain_total   : String = &""
## When the shape is revealed a bit more, but not fully
var sfx_visibility_gain_partial : String = &""
## When the shape lose some visibility (either total or partial)
var sfx_visibility_lose : String = &""
## When destroyed because it is frage
var sfx_fragile_break : String = &""

## For setting sfx_visibility_gain_total and sfx_visibility_gain_partial
var sfx_visibility_gain : String:
	set(value):
		sfx_visibility_gain_total = value
		sfx_visibility_gain_partial = value
#endregion

#region Trait Tiled. Thank godot for not supporting them...
func on_tile_added():
	self.on_tile_changed()
	
func on_tile_removed():
	self.on_tile_changed()
	if area:
		self.area.sfx.play(self.sfx_dig)
	if self.is_fragile:
		if area:
			self.area.sfx.play(self.sfx_fragile_break);
		self.clear_tile()
		
func _add_tile(pos: Vector2i, tile: Tile = null) -> Shape:
	if tile == null:
		tile = _default_tile.duplicate()
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

# Tp the top left tile corner at the given pos
func set_tile_pos_origin(delta: Vector2i) -> Shape:
	return self.move_all_tile(-self.bounding_box().position + delta)

func move_all_tile(delta: Vector2i) -> Shape:
	if delta == Vector2i.ZERO:
		return self
	
	var old_tiles = _tiles.duplicate()
	
	for pos in old_tiles:
		self._remove_tile(pos)
	
	_tiles.clear()
	
	for pos in old_tiles:
		self._add_tile(pos + delta, old_tiles[pos])
	
	self.render_node.position += Vector2(delta) * ShapeSprite.ZOOM;
	return self

func add_tile(pos: Vector2i, tile: Tile = null) -> Shape:
	if tile == null:
		tile = _default_tile.duplicate()
	self._add_tile(pos, tile)
	self.on_tile_added()
	return self
	
func add_tile_rect(rect: Rect2i, tile: Tile = null) -> Shape:
	if tile == null:
		tile = _default_tile.duplicate()
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			self._add_tile(Vector2i(x, y), tile.duplicate())
	self.on_tile_added()
	return self

# Helper method
func add_tile_rect_size(size_x:int, size_y: int, tile: Tile = null) -> Shape:
	return self.add_tile_rect(Rect2i(0,0,size_x,size_y))

func add_all_tile(elements: Array[Vector2i], tile: Tile = null) -> Shape:
	if tile == null:
		tile = _default_tile.duplicate()
	for pos in elements:
		#print(pos)
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
	
func overlap(other: Shape) -> bool:
	# That lambda syntax..., the need to use the `return` kw... 
	return self.tiles().any(func(tile): return other.contains_tile(tile))

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

# I can't imagine having a pile of dirt that is a treasure
@export var is_treasure : bool = false

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
		
		if self.is_treasure:
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

func is_collected() -> bool:
	return self.nb_tile_visible == self.nb_tile() && self.is_treasure
	
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
	self.update_render()
	
func update_render():
	if area && !area.is_generating:
		self.sprite.update_render(self, render_node)

func _ready() -> void:
	add_child(self.render_node)




#region Preset

func preset_set_tile_max_hp(hp_max: int):
	self._default_tile.with_hp_max(hp_max).with_hp(hp_max)
	for pos in self._tiles:
		self._tiles[pos].with_hp_max(hp_max).with_hp(hp_max)
	

func preset_tileset_rock() -> Shape:
	preset_set_tile_max_hp(3)
	self.sfx_dig = &"rock_dig"
	self.sfx_damage = &"rock_damage"
	self.sprite = ShapeSprite.ROCK
	self.is_destructible = true
	self.absorb_dig = true
	return self.preset_layer_foreground()
	
func preset_tileset_leaf() -> Shape:
	preset_set_tile_max_hp(2)
	self.sfx_dig = &"leaf_dig"
	self.sfx_damage = &"leaf_damage"
	self.sprite = ShapeSprite.LEAF
	self.is_destructible = true
	self.absorb_dig = true
	return self.preset_layer_foreground()
	
func preset_tileset_sand() -> Shape:
	preset_set_tile_max_hp(1)
	self.sfx_dig = &"sand_dig"
	self.sfx_damage = &"sand_damage"
	self.sprite = ShapeSprite.SAND
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
	self.shape_name =  GE.ShapeName.Bracelet
	self.add_tile_rect_size(3,3)
	self.remove_tile(Vector2i(1,1))
	return self.preset_treasure()
	
func preset_treasure_bat_talisman() -> Shape:
	self.sprite = ShapeSprite.BAT_TALISMAN
	self.shape_name =  GE.ShapeName.BatTalisman
	self.add_tile_rect_size(3,1)
	self.sfx_visibility_gain_total = &"bat_talisman"
	return self.preset_treasure()
	
func preset_treasure_boomerang() -> Shape:
	self.sprite = ShapeSprite.BOOMERANG
	self.shape_name =  GE.ShapeName.Boomerang
	self.add_all_tile(
		[
			Vector2i(0,0), Vector2i(0,1), Vector2i(1,0),
		])
	self.sfx_visibility_gain_total = &"boomerang"
	return self.preset_treasure()

func preset_treasure_diamound() -> Shape:
	self.sprite = ShapeSprite.DIAMOUND
	self.shape_name =  GE.ShapeName.Diamound
	self.add_tile_rect_size(2,2)
	self.sfx_visibility_gain_total = &"diamound"
	return self.preset_treasure()

func preset_treasure_snake() -> Shape:
	self.sprite = ShapeSprite.SNAKE
	self.shape_name =  GE.ShapeName.Snake
	self.add_tile_rect_size(5,3)
	self.remove_tile(Vector2i(1,1))
	self.remove_tile(Vector2i(3,0))
	self.remove_tile(Vector2i(5,1))
	self.sfx_visibility_gain_total = &"snake"
	return self.preset_treasure()

func preset_treasure_glued_stone() -> Shape:
	self.sprite = ShapeSprite.GLUED_STONE
	self.shape_name =  GE.ShapeName.GluedStone
	self.add_tile_rect_size(3,3)
	self.remove_tile(Vector2i(0,0))
	self.remove_tile(Vector2i(2,2))
	self.sfx_visibility_gain_total = &"glued_stone"
	return self.preset_treasure()

func preset_treasure_horseshoe_crab() -> Shape:
	self.sprite = ShapeSprite.HORSESHOE_CRAB
	self.shape_name =  GE.ShapeName.HorshoeCrab
	self.add_tile_rect_size(3,3)
	self.sfx_visibility_gain_total = &"horseshoe_crab"
	return self.preset_treasure()

func preset_treasure_peru_knife() -> Shape:
	self.sprite = ShapeSprite.PERU_KNIFE
	self.shape_name =  GE.ShapeName.PeruKnife
	self.add_tile_rect_size(1,3)
	self.sfx_visibility_gain_total = &"peru_knife"
	return self.preset_treasure()

func preset_treasure_red_gem() -> Shape:
	self.sprite = ShapeSprite.RED_GEM
	self.shape_name =  GE.ShapeName.RedGem
	self.add_tile_rect_size(2,2)
	self.sfx_visibility_gain_total = &"red_gem"
	return self.preset_treasure()

func preset_treasure_roman_ruler() -> Shape:
	self.sprite = ShapeSprite.ROMAN_RULER
	self.shape_name =  GE.ShapeName.RomanRuler
	self.add_tile_rect_size(1,3)
	self.add_tile_rect(Rect2i(0,2,3,1))
	self.sfx_visibility_gain_total = &"roman_ruler"
	return self.preset_treasure()

func preset_treasure_ruby() -> Shape:
	self.sprite = ShapeSprite.RUBY
	self.shape_name =  GE.ShapeName.Ruby
	self.add_tile_rect_size(2,2)
	return self.preset_treasure()

func preset_treasure_shell() -> Shape:
	self.sprite = ShapeSprite.SHELL
	self.shape_name =  GE.ShapeName.Shell
	self.add_tile_rect_size(3,3)
	return self.preset_treasure()

func preset_treasure_skara_brae() -> Shape:
	self.sprite = ShapeSprite.SKARA_BRAE
	self.shape_name =  GE.ShapeName.SkaraBrae
	self.add_tile_rect_size(3,1)
	self.add_tile(Vector2i(1,1))
	return self.preset_treasure()

func preset_treasure_skull_saber() -> Shape:
	self.sprite = ShapeSprite.SKULL_SABER
	self.shape_name =  GE.ShapeName.SkullSaber
	self.sfx_visibility_gain_total = &"skull_saber"
	self.add_tile_rect_size(3,3)
	return self.preset_treasure()

func preset_treasure_tenon_head() -> Shape:
	self.sprite = ShapeSprite.TENON_HEAD
	self.shape_name =  GE.ShapeName.TenonHead
	self.add_tile_rect_size(2,2)
	return self.preset_treasure()

func preset_treasure_trex() -> Shape:
	self.sprite = ShapeSprite.TREX
	self.shape_name =  GE.ShapeName.Trex
	self.add_tile_rect_size(5,4)
	self.remove_tile(Vector2i(0,2))
	self.remove_tile(Vector2i(1,2))
	self.sfx_visibility_gain_total = &"trex"
	return self.preset_treasure()

func preset_treasure_microwave() -> Shape:
	self.sprite = ShapeSprite.MICROWAV
	self.shape_name =  GE.ShapeName.Microwav
	self.add_tile_rect_size(3,2)
	self.sfx_visibility_gain_total = &"microwave"
	return self.preset_treasure()

func preset_treasure(offset = 0) -> Shape:
	self.preset_layer_treasure(offset)
	self.is_treasure = true
	self.is_destructible = false
	self.absorb_dig = true
	self.is_fragile = false
	#self.shape_name = name
	if self.sfx_visibility_gain_partial.is_empty():
		self.sfx_visibility_gain_partial = "treasure_reveal_partial"
	if self.sfx_visibility_gain_total.is_empty():
		self.sfx_visibility_gain_total = "treasure_reveal_total"
	if self.sfx_visibility_lose.is_empty():
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
#endregion
