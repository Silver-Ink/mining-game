extends Resource
class_name ShapeSprite

var tileset : Texture2D = null
var per_tile : Sprite2D  = null
var global : Sprite2D = null

const SIZE : int = 8
const SCALE : Vector2 = Vector2(1./ SIZE, 1./ SIZE)
const HALF_SCALE : Vector2 = SCALE / 2.;

func generate(shape: Shape) -> Node2D:
	var node = Node2D.new()
	return self.append(shape, node)

func clear(node: Node2D) -> Node2D:
	for child in node.get_children():
		child.queue_free()
	return node
	
func update(shape: Shape, node: Node2D) -> Node2D:
	return append(shape, clear(node))

# Append the subnode/drawing instruction into the node
func append(shape: Shape, node: Node2D) -> Node2D:
	if per_tile:
		for tile in shape.tiles():
			var new_sprite = per_tile.duplicate()
			new_sprite.position = Vector2(tile.x * SIZE, tile.y * SIZE)
			node.add_child(new_sprite)
		
	if tileset:
		for tile in shape.tiles():
			const REMAP = [3, 2, 0, 1]
			var idx_x = REMAP[(shape.contains(tile + Vector2i(-1,0)) as int) + (shape.contains(tile + Vector2i(+1,0)) as int * 2)]
			var idx_y = REMAP[(shape.contains(tile + Vector2i(0,-1)) as int) + (shape.contains(tile + Vector2i(0,+1)) as int * 2)]
			
			var new_sprite = Sprite2D.new()
			new_sprite.texture = tileset
			new_sprite.centered = true
			new_sprite.region_enabled = true
			new_sprite.region_rect = Rect2i(idx_x * SIZE, idx_y * SIZE, SIZE, SIZE)
			new_sprite.scale = Vector2.ONE;
			new_sprite.position = Vector2(tile.x * SIZE, tile.y * SIZE) - HALF_SCALE;
			node.add_child(new_sprite)
	
	if global:
		node.add_child(global.duplicate())
	
	return node


static func from_tileset(uid : String) -> ShapeSprite:
	var s = new()
	s.tileset = load(uid)
	return s
	
static var BONE : ShapeSprite = ShapeSprite.from_tileset("uid://bmb7m3xfcik21")
static var ROCK : ShapeSprite = ShapeSprite.from_tileset("uid://dh8ficnqa4uqq")
static var SAND : ShapeSprite = ShapeSprite.from_tileset("uid://ig4wnf2j7ufe")
static var WALL : ShapeSprite = ShapeSprite.from_tileset("uid://e37kapqjwwh2")
