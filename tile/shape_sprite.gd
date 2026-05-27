extends Node2D
class_name ShapeSprite

#@export var tiled_node : Node2D = Node2D.new()
@export var tiled_sprite : Sprite2D = Sprite2D.new()
@export var global_sprite : Sprite2D = Sprite2D.new()
const TILE_SIZE : int = 8

func update(shape: Shape):
	for child in get_children():
		child.queue_free()

	for tile in shape.tiles():
		var new_sprite = tiled_sprite.duplicate()
		new_sprite.position = Vector2(tile.x * TILE_SIZE, tile.y * TILE_SIZE)
		add_child(new_sprite)
		# TODO: fix the pos
		#var new_tiled_node = tiled_node.duplicate()
		#new_tiled_node.position = Vector2(tile.x * TILE_SIZE, tile.y * TILE_SIZE)
		#add_child(new_tiled_node)
	
	var new_global = global_sprite.duplicate()
	add_child(new_global)
