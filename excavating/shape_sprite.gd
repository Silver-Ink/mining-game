extends Resource
class_name ShapeSprite

var tileset : Array[Texture2D] = []
var per_tile : Sprite2D  = null
var global : Sprite2D = null

const SIZE : int = 8

const ZOOM : Vector2 = Vector2(SIZE, SIZE)

const SCALE : Vector2 = Vector2(1./ SIZE, 1./ SIZE)
const HALF_SCALE : Vector2 = SCALE / 2.;

func generate_render(shape: Shape) -> Node2D:
	var node = Node2D.new()
	return self.append_render(shape, node)

func clear_render(node: Node2D) -> Node2D:
	for child in node.get_children():
		child.queue_free()
	return node

func update_render(shape: Shape, node: Node2D) -> Node2D:
	return append_render(shape, clear_render(node))

# Append the subnode/drawing instruction into the node
func append_render(shape: Shape, node: Node2D) -> Node2D:
	if per_tile:
		for tile in shape.tiles():
			var new_sprite = per_tile.duplicate()
			new_sprite.position = Vector2(tile.x * SIZE, tile.y * SIZE)
			node.add_child(new_sprite)
		
	if tileset && tileset.size() >= 1:
		var tileset_max_idx = self.tileset.size() - 1
		for tile in shape.tiles():
			const REMAP = [3, 2, 0, 1]
			var idx_x = REMAP[(shape.contains_tile(tile + Vector2i(-1,0)) as int) + (shape.contains_tile(tile + Vector2i(+1,0)) as int * 2)]
			var idx_y = REMAP[(shape.contains_tile(tile + Vector2i(0,-1)) as int) + (shape.contains_tile(tile + Vector2i(0,+1)) as int * 2)]
			
			var coef = shape.get_tile(tile).hp_coef()
			var destruction_idx : int = tileset_max_idx - ((coef * tileset_max_idx) as int)
			
			var new_sprite = Sprite2D.new()
			new_sprite.texture = tileset[destruction_idx]
			new_sprite.centered = true
			new_sprite.region_enabled = true
			new_sprite.region_rect = Rect2i(idx_x * SIZE, idx_y * SIZE, SIZE, SIZE)
			new_sprite.scale = Vector2.ONE;
			new_sprite.position = Vector2(tile.x * SIZE, tile.y * SIZE) - HALF_SCALE;
			node.add_child(new_sprite)
	
	if global:
		node.add_child(global.duplicate())
	
	return node


func add_tileset(texture_uid : String) -> ShapeSprite:
	self.tileset.append(load(texture_uid))
	return self
	
func set_tile_sprite(texture_uid : String) -> ShapeSprite:
	self.per_tile = Sprite2D.new()
	self.per_tile.texture = load(texture_uid)
	return self


func add_global_sprite(texture_uid : String) -> ShapeSprite:
	self.global = Sprite2D.new()
	self.global.texture = load(texture_uid)
	#self.global.offset = ((self.global.texture.get_size() / ZOOM) * 0.5).floor() * ZOOM
	self.global.offset = ((self.global.texture.get_size() / ZOOM) * 0.5) * ZOOM - ZOOM / 2
	return self
	
static var SHAPE_DEF : Dictionary[GE.ShapeName, ShapeSprite] = {
	
	
	GE.ShapeName.Bone : ShapeSprite.new().add_tileset("uid://bmb7m3xfcik21"),

	# Currently use stone
	GE.ShapeName.Rock : ShapeSprite.new() \
		.add_tileset("uid://carpwq7xyvjlx") \
		.add_tileset("uid://xxs0i1s6ih7p") \
		.add_tileset("uid://biqcjps7tf2xc"),

	GE.ShapeName.Leaf : ShapeSprite.new() \
		.add_tileset("uid://tetbgpjanx8u") \
		.add_tileset("uid://bktw8wydqr5r4"),
		
	 GE.ShapeName.Sand : ShapeSprite.new().add_tileset("uid://ig4wnf2j7ufe"),
	 GE.ShapeName.Wall : ShapeSprite.new().add_tileset("uid://e37kapqjwwh2"),

	 GE.ShapeName.Bracelet : ShapeSprite.new().add_global_sprite("uid://bgau2khqls2d7"),
	 GE.ShapeName.BatTalisman : ShapeSprite.new().add_global_sprite("uid://c0vyi4qn8uj1s"),
	 GE.ShapeName.Boomerang : ShapeSprite.new().add_global_sprite("uid://diwa4wudtt3bn"),
	 GE.ShapeName.Diamound : ShapeSprite.new().add_global_sprite("uid://cryqh1j2hcevb"),
	 GE.ShapeName.Snake : ShapeSprite.new().add_global_sprite("uid://dwchpcqg2s83u"),
	 GE.ShapeName.GluedStone : ShapeSprite.new().add_global_sprite("uid://c8tg4nsa5xkpv"),
	 GE.ShapeName.HorshoeCrab : ShapeSprite.new().add_global_sprite("uid://codvb8om2nl7v"),
	 GE.ShapeName.PeruKnife : ShapeSprite.new().add_global_sprite("uid://claydltshnn5x"),
	 GE.ShapeName.RedGem : ShapeSprite.new().add_global_sprite("uid://b77p5v7aqsy3s"),
	 GE.ShapeName.RomanRuler : ShapeSprite.new().add_global_sprite("uid://0fxe2x3fn0pl"),
	 GE.ShapeName.Ruby : ShapeSprite.new().add_global_sprite("uid://brrjup8j806h3"),
	 GE.ShapeName.Shell : ShapeSprite.new().add_global_sprite("uid://c2suucd6ch50s"),
	 GE.ShapeName.SkaraBrae : ShapeSprite.new().add_global_sprite("uid://d2jliyw6wry15"),
	 GE.ShapeName.SkullSaber : ShapeSprite.new().add_global_sprite("uid://bweivsk68aasj"),
	 GE.ShapeName.TenonHead : ShapeSprite.new().add_global_sprite("uid://di5pr228d1n1"),
	 GE.ShapeName.Trex : ShapeSprite.new().add_global_sprite("uid://drwo01r6ughp6"),
	 GE.ShapeName.Microwav : ShapeSprite.new().add_global_sprite("uid://bwljdrkcdfslv")
}
