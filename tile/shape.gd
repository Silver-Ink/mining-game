@icon("res://icons/shape_icon.svg")
extends Node2D
class_name Shape

#region Trait Tiled. Thank godot for not supporting them...
func add(element: Vector2i) -> Shape:
	self._tile.add(element);
	on_tile_added()
	return self

func add_rect(rect: Rect2i) -> Shape:
	self._tile.add_rect(rect);
	on_tile_added()
	return self

func add_all(elements: Array[Vector2i]) -> Shape:
	self._tile.add_all(elements);
	on_tile_added()
	return self

func merge(other: Tiles) -> Shape:
	self._tile.merge(other)
	on_tile_added()
	return self

func remove(element: Vector2i) -> bool:
	if self._tile.remove(element):
		if area:
			area._lookup[element].erase(self)
		on_tile_removed()
		return true
	return false

func remove_all(elements: Array[Vector2i]):
	var removed = self._tile.remove_all(elements)
	if removed.size() >= 1:
		if area:
			for element in removed:
				area._lookup[element].erase(self)
		on_tile_removed()
	return removed

func contains(element: Vector2i) -> bool:
	return self._tile.contains(element)

func tiles() -> Array[Vector2i]:
	return self._tile.tiles()

func clear():
	if not is_empty():
		for element in self.tiles():
			self.remove(element)
		#self._tile.clear()
		on_tile_removed()

func is_empty():
	return _tile.is_empty()

func size():
	return _tile.size()

func bounding_box() -> Rect2i:
	return _tile.bounding_box()
	
func move_all(delta: Vector2i):
	_tile.move_all(delta)
	self.render_node.move_local_x(delta.x)
	self.render_node.move_local_y(delta.y)
#endregion End of the Tiled Trait

#region Shape properties
## Per Shape for the moment. Can be moved per _tile if needed YAGNI :)
var is_destructible: bool = false
## destorying 1 tile = destorying all tiles
var is_fragile: bool = false
#endregion

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


func on_tile_added():
	on_tile_changed()
	
func on_tile_removed():
	on_tile_changed()
	if is_fragile:
		clear()
	
func on_tile_changed():
	self.sprite.update(self, render_node)
	


func _ready() -> void:
	add_child(self.render_node)


func preset_tileset_rock() -> Shape:
	self.sprite = ShapeSprite.ROCK
	self.is_destructible = true
	return self.preset_layer_foreground()
	
func preset_tileset_background() -> Shape:
	self.sprite = ShapeSprite.WALL
	self.is_destructible = false
	return self.preset_layer_background()
	
func preset_tileset_bone() -> Shape:
	self.sprite = ShapeSprite.BONE
	self.is_destructible = true
	self.is_fragile = true
	return self.preset_layer_treasure()
	
func preset_tileset_bracelet() -> Shape:
	self.sprite = ShapeSprite.BRACELET
	self.add_all(
		[
			# Un petit côté Alain D.
			Vector2i(0,0), Vector2i(1,0), Vector2i(2,0),
			Vector2i(0,1)               , Vector2i(2,1),
			Vector2i(0,2), Vector2i(1,2), Vector2i(2,2),
		])
	return self.preset_layer_treasure()
	
enum Layer 
{
	BACKGROUND = -100,
	TREASURE = 100,
	#FOREGROUND = 200,
	FOREGROUND = 50,
}

func preset_layer(layer: Layer, offset = 0) -> Shape:
	self.height = layer + offset
	return self

func preset_layer_background(offset = 0) -> Shape:
	return self.preset_layer(Layer.BACKGROUND, offset)
	
func preset_layer_treasure(offset = 0) -> Shape:
	return self.preset_layer(Layer.TREASURE, offset)

func preset_layer_foreground(offset = 0) -> Shape:
	return self.preset_layer(Layer.FOREGROUND, offset)
