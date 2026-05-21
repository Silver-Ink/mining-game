class_name GameAreaLayout

var size : Vector2i = Vector2i(16,9);

static func default() -> GameAreaLayout:
	var default_layout = GameAreaLayout.new()
	return default_layout

func generate() -> GameArea:
	var area = GameArea.new(self)
	return area
