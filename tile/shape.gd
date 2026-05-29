@icon("res://icons/shape_icon.svg")
extends Node2D
class_name Shape

# Begin of the Tile Trait / Interface, thank godot for supporting them

func add(element: Vector2i) -> Shape:
	self._tile.add(element);
	on_tile_changed()
	return self
	
func add_rect(rect: Rect2i) -> Shape:
	self._tile.add_rect(rect);
	on_tile_changed()
	return self

func add_all(elements: Array[Vector2i]) -> Shape:
	self._tile.add_all(elements);
	on_tile_changed()
	return self

func merge(other: Tiles) -> Shape:
	self._tile.merge(other)
	on_tile_changed()
	return self

func remove(element):
	self._tile.remove(element)
	on_tile_changed()

func remove_all(elements):
	self._tile.remove_all(elements)
	on_tile_changed()

func contains(element) -> bool:
	return self._tile.contains(element)

func tiles() -> Array[Vector2i]:
	return self._tile.tiles()

func clear():
	self._tile.clear()
	on_tile_changed()

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
	
# End of the Tiled Trait

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

# Per Shape for the moment. Can be moved per _tile if needed YAGNI :)
var is_destructible: bool

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
	
var sprite: ShapeSprite = ShapeSprite.new():
	get:
		return sprite
	set(value):
		sprite = value
		assert(render_node != null)
		sprite.update(self, render_node)


func on_tile_changed():
	self.sprite.update(self, render_node)
	
func preset_rock():
	self.sprite = ShapeSprite.ROCK
	self.is_destructible = true

func _ready() -> void:
	add_child(self.render_node)


static func item_bat_talisman() -> Shape:
	var s = new()
	s._tile.add_rect(Rect2i(0,0,3,1));
	assert(false, "todo")
	#s.sprite = ShapeSprite.SAND
	#s.sprite.global_sprite = Assets
	return s
