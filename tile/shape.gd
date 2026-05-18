extends Node2D
class_name Shape

var tile: Tiles = Tiles.new():
	get:
		return tile
	set(value):
		if map:
			map.remove(self)
		tile = value
		if map:
			map.insert(self)
			
var level : int = 0:
	get:
		return level
	set(value):
		level = value
	
var map: ShapeManager = null:
	get:
		return map
	set(value):
		if map == value:
			return
		if map != null:
			var m = map;
			map = null;
			m.remove(self)
		
		map = value
		if value != null:
			value.insert(self)
			
var sprite: ShapeSprite = ShapeSprite.new()

func tiles() -> Array[Vector2i]:
	return tile.tiles()

func bounding_box() -> Rect2i:
	return tile.bounding_box()

func move(delta: Vector2i):
	self.map.move(self, delta)

func on_tiles_changed():
	self.sprite.update(self)
	
func _ready() -> void:
	add_child(self.sprite)
