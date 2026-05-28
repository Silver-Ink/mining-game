extends Node2D
class_name ShapeSprite

@export var tiled_sprite : Sprite2D = Sprite2D.new() #? demander juste la texture ?
@export var global_sprite : Sprite2D = Sprite2D.new() #? enlever et laisser juste les enfants ?
const TILE_SIZE : int = 8

func update(shape: Shape):
	for child in get_children():
		child.queue_free()

	for tile in shape.tiles():
		var new_sprite = tiled_sprite.duplicate()
		# TODO: fix the pos
		new_sprite.position = Vector2(tile.x * TILE_SIZE, tile.y * TILE_SIZE)
		add_child(new_sprite)
	
	var new_global = global_sprite.duplicate()
	add_child(new_global)
