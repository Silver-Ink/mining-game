class_name GameAreaGenerator

var size : Vector2i = Vector2i(16,9);
var rect : Rect2i:
	get:
		return Rect2i(0,0, size.x, size.y)

var min_treasure : int = 0
var max_treasure : int = 0

var wished_treasure : Array[GE.ShapeName];

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
	
	l.spawn_shape(GE.ShapeName.Bg).add_tile_rect(rect)
	#l.spawn_shape(GE.ShapeName.Rock).add_tile_rect(rect)
	l.spawn_shape(GE.ShapeName.Bone).add_tile_rect(Rect2i(size.x / 2 - 1,size.y / 2 - 1,3,3))
	
	l.spawn_shape(GE.ShapeName.Bracelet)#.move_all_tile(Vector2(2,3))
	l.spawn_shape(GE.ShapeName.Boomerang)#.move_all_tile(Vector2(5,4))
	#var bracelet = Shape.new().preset_treasure_bracelet()
	#bracelet.move_all_tile(Vector2(2,3))
	#bracelet.area = l;
	
	
