@icon("res://icons/shape_icon.svg")
extends Node2D
class_name Shape

@export var tile: Tiles = Tiles.new():
	get:
		return tile
	set(value):
		if area:
			area.remove(self)
		tile = value
		if area:
			area.insert(self)

@export var sprite_scene: PackedScene

var sprite : ShapeSprite

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
			
func _ready() -> void:
	sprite = sprite_scene.instantiate()
	add_child(sprite)

func tiles() -> Array[Vector2i]:
	return tile.tiles()

func bounding_box() -> Rect2i:
	return tile.bounding_box()

func move(delta: Vector2i):
	self.map.move(self, delta) #?

func on_tiles_changed():
	self.sprite.update(self)
	
