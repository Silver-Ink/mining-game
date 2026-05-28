extends Node2D
class_name ShapeSprite

#@export var tiled_node : Node2D = Node2D.new()
#@export var tileset : TileSet = null
@export var tileset_sprite : Sprite2D = null
@export var tiled_sprite : Sprite2D  = null
@export var global_sprite : Sprite2D = null
const TILE_SIZE : int = 8
const TILE_SCALE : Vector2 = Vector2(1./ TILE_SIZE, 1./ TILE_SIZE)

func update(shape: Shape):
	for child in get_children():
		child.queue_free()

	
	if tiled_sprite:
		for tile in shape.tiles():
			var new_sprite = tiled_sprite.duplicate()
			new_sprite.position = Vector2(tile.x * TILE_SIZE, tile.y * TILE_SIZE)
			add_child(new_sprite)
		# TODO: fix the pos
		#var new_tiled_node = tiled_node.duplicate()
		#new_tiled_node.position = Vector2(tile.x * TILE_SIZE, tile.y * TILE_SIZE)
		#add_child(new_tiled_node)
		
	if tileset_sprite:
		var idx_x = 0
		var idx_y = 0
		for tile in shape.tiles():
			idx_x += 3 - ((shape.tile.contains(tile + Vector2i(-1,0)) as int) + (shape.tile.contains(tile + Vector2i(+1,0)) as int * 2))
			idx_y += 3 - ((shape.tile.contains(tile + Vector2i(0,-1)) as int) + (shape.tile.contains(tile + Vector2i(0,+1)) as int * 2))
			
			var new_sprite = tileset_sprite.duplicate()
			new_sprite.centered = false
			new_sprite.region_enabled = true
			new_sprite.region_rect = Rect2i(idx_x * TILE_SIZE, idx_y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			#print(tile)
			new_sprite.position = Vector2(tile.x * TILE_SIZE, tile.y * TILE_SIZE)
			add_child(new_sprite)
	
	if global_sprite:
		var new_global = global_sprite.duplicate()
		add_child(new_global)
	


static func tileset(uid : String) -> ShapeSprite:
	var s = new()
	s.tileset_sprite = Sprite2D.new()
	s.tileset_sprite.texture = load(uid) # pretty sure it is not opti / will be duplicated
	s.tileset_sprite.scale = 4 * TILE_SCALE;
	return s


static func bone() -> ShapeSprite:
	return tileset("uid://bmb7m3xfcik21")

static func rock() -> ShapeSprite:
	return tileset("uid://dh8ficnqa4uqq")
	
static func sand() -> ShapeSprite:
	return tileset("uid://ig4wnf2j7ufe")
	
static func wall() -> ShapeSprite:
	return tileset("uid://e37kapqjwwh2")
	
static func test() -> ShapeSprite:
	var s = new()
	s.tiled_sprite = Sprite2D.new()
	s.tiled_sprite.texture = load("uid://2g21uorfwa3a") # pretty sure it is not opti / will be duplicated
	s.tiled_sprite.scale = TILE_SCALE;
	return s
