class_name GameAreaGenerator

var size : Vector2i = Vector2i(16,9);

static func default() -> GameAreaGenerator:
	var default_generator = GameAreaGenerator.new() #?
	return default_generator

func instanciate() -> GameArea:
	var area = GameArea.new(self)
	return area

func generate_in(l: GameArea):
	l.is_generating = true
	self._generate(l)
	l.is_generating = false
	
	
func _generate(l: GameArea):
	
	l.clear()
	
	var bg : Shape = Shape.new();
	bg.add_tile_rect(Rect2i(0,0,size.x,size.y), Tile.new())
	bg.preset_tileset_background()
	bg.area = l;
	
	var rock : Shape = Shape.new();
	rock.add_tile_rect(Rect2i(0,0,size.x,size.y), Tile.new().with_hp_max(3).with_hp(3))
	rock.preset_tileset_rock()
	rock.area = l;
	
	var bone = Shape.new();
	bone.add_tile_rect(Rect2i(size.x / 2 - 1,size.y / 2 - 1,3,3), Tile.new())
	bone.preset_tileset_bone()
	bone.area = l;
	
	var bracelet = Shape.new().preset_treasure_bracelet()
	print(bracelet.tiles())
	bracelet.move_all_tile(Vector2(2,3))
	print(bracelet.tiles())
	bracelet.area = l;
	
	
