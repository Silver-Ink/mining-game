@icon("res://icons/shape_icon.svg")
extends Node2D
class_name Shape

#region Trait Tiled. Thank godot for not supporting them...
func on_tile_added():
	on_tile_changed()
	
func on_tile_removed():
	on_tile_changed()
	if is_fragile && !is_empty():
		clear()
		
func _add(element: Vector2i) -> Shape:
	self._tile.add(element)
	if area:
		area._shape_add_tile(self, element)
	return self

func _remove(element: Vector2i) -> bool:
	if self._tile.remove(element):
		if area:
			area._shape_remove_tile(self, element)
		return true
	return false

func contains(element: Vector2i) -> bool:
	return self._tile.contains(element)

func tiles() -> Array[Vector2i]:
	return self._tile.tiles()
	
func bounding_box() -> Rect2i:
	return _tile.bounding_box()
	
func move_all(delta: Vector2i):
	_tile.move_all(delta)
	self.render_node.position += Vector2(delta) * ShapeSprite.ZOOM;
	#self.render_node.move_local_x(delta.x)
	#self.render_node.move_local_y(delta.y)

#region Default impl
func add(element: Vector2i) -> Shape:
	_add(element)
	on_tile_added()
	return self
	
func add_rect(rect: Rect2i) -> Shape:
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			_add(Vector2i(x, y))
	on_tile_added()
	return self

func add_all(elements: Array[Vector2i]) -> Shape:
	for element in elements:
		_add(element)
	on_tile_added()
	return self

func merge(other: Tiles) -> Shape:
	add_all(other.tiles())
	return self

func remove(element: Vector2i) -> bool:
	var removed = _remove(element)
	if removed:
		on_tile_removed()
	return removed

func remove_all(elements: Array[Vector2i]) -> Array[Vector2i]:
	var removed = []
	for element in elements:
		if _remove(element):
			removed.append(element)
	on_tile_removed()
	return removed


func nb_tile() -> int:
	return tiles().size() # Not opti because we don't need cloning the tiles

func clear():
	for t in tiles():
		self._remove(t)
	on_tile_removed()

func is_empty():
	return nb_tile() <= 0
#endregion
#endregion End of the Tiled Trait

#region Shape properties
## Is concerned by the action of digging
var absorb_dig: bool = true

## Per Shape for the moment. Can be moved per _tile if needed YAGNI :)
var is_destructible: bool = true

## destroying 1 tile = destroying all tiles
var is_fragile: bool = false

var nb_tile_visible : int = 0:
	get:
		return nb_tile_visible
	set(value):
		if nb_tile_visible == value:
			return
		nb_tile_visible = value
		
		#print()
		#print()
		#print()
		#print("tile visible: " + str(nb_tile_visible) + " / " + str(nb_tile()) + " = " + str(coef_tile_visible() * 100.) + " %")
		
#endregion


func coef_tile_visible() -> float:
	var nb_tile = nb_tile()
	if nb_tile != 0:
		return nb_tile_visible as float / nb_tile() as float
	return 0.

#@export var _tile: Tiles = Tiles.new():
var _tile: Tiles = Tiles.new():
	get:
		return _tile
	set(value):
		if area:
			area.remove(self)
		_tile = value
		if area:
			area.insert(self)


# Z level
var height : int = 0:
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


func with_area(area: GameArea) -> Shape:
	self.area = area
	return self

	
var sprite: ShapeSprite = ShapeSprite.new():
	get:
		return sprite
	set(value):
		sprite = value
		assert(render_node != null)
		sprite.update(self, render_node)



	
func on_tile_changed():
	self.sprite.update(self, render_node)
	


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
	self.absorb_dig = true
	return self.preset_layer_treasure()


func preset_treasure_bracelet() -> Shape:
	self.sprite = ShapeSprite.BRACELET
	self.add_all(
		[
			# Un petit côté Alain D.
			Vector2i(-1,-1), Vector2i(0,-1), Vector2i(1,-1),
			Vector2i(-1, 0)                , Vector2i(1, 0),
			Vector2i(-1, 1), Vector2i(0,1) , Vector2i(1, 1),
		])
	return self.preset_treasure()
	
enum Layer 
{
	BACKGROUND = -100,
	TREASURE = 100,
	#FOREGROUND = 200,
	FOREGROUND = 50, # For debugging
}

func preset_treasure(offset = 0) -> Shape:
	self.preset_layer_treasure(offset)
	self.is_destructible = false
	self.absorb_dig = true
	self.is_fragile = false
	return self

func preset_layer(layer: Layer, offset = 0) -> Shape:
	self.height = layer + offset
	return self

func preset_layer_background(offset = 0) -> Shape:
	return self.preset_layer(Layer.BACKGROUND, offset)
	
func preset_layer_treasure(offset = 0) -> Shape:
	return self.preset_layer(Layer.TREASURE, offset)

func preset_layer_foreground(offset = 0) -> Shape:
	return self.preset_layer(Layer.FOREGROUND, offset)
