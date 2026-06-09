class_name GameAreaGenerator

var size : Vector2i = Vector2i(16,9);
var rect : Rect2i:
	get:
		return Rect2i(0,0, size.x, size.y)

var min_treasure : int = 3
var max_treasure : int = 6

var treasures : Array[GE.ShapeName];

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
	
	var treasure : Array[Shape] = []
	
	for i in range(randi_range(min_treasure, max_treasure)):
		var shape_name = treasures.pop_back()
		if !shape_name:
			shape_name = GE.ShapeNameTreasure.pick_random()
		
		var shape = l.spawn_shape(shape_name)
		var bb = shape.bounding_box()
		
		shape.set_tile_pos_origin(Vector2(randi_range(0, size.x - bb.size.x), randi_range(0, size.y - bb.size.y)))
		treasure.append(shape)
	
	# can do way better in term of complexity
	#
	var max_move = 1000
	for it_idx in range(max_move):
		var i = randi_range(0, treasure.size()-1)
		for j in range(0, treasure.size()):
			if i == j:
				continue
			
			var shape = treasure[i]
			
			for it_idx_2 in range(50):
				if shape.overlap(treasure[j]):
					var bb = shape.bounding_box()
					shape.set_tile_pos_origin(Vector2(randi_range(0, size.x - bb.size.x), randi_range(0, size.y - bb.size.y)))
				else:
					break
	
	#l.spawn_shape(GE.ShapeName.Rock).add_tile_rect(rect)
	#l.spawn_shape(GE.ShapeName.Leaf).add_tile_rect(rect)
	#l.spawn_shape(GE.ShapeName.Bone).add_tile_rect(Rect2i(size.x / 2 - 1,size.y / 2 - 1,3,3))
	
	#l.spawn_shape(GE.ShapeName.Bracelet)#.move_all_tile(Vector2(2,3))
	#l.spawn_shape(GE.ShapeName.Boomerang).move_all_tile(Vector2(3,5))
	#var bracelet = Shape.new().preset_treasure_bracelet()
	#bracelet.move_all_tile(Vector2(2,3))
	#bracelet.area = l;
	
	
