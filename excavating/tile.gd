class_name Tile

var hp: int
var hp_max: int

func hp_coef() -> float:
	return self.hp as float / self.hp_max as float
	
func _init() -> void:
	self.with_hp_max(1).with_hp(1)

func with_hp(hp: int) -> Tile:
	self.hp = clamp(hp, 0, self.hp_max)
	return self

func with_hp_max(hp_max: int) -> Tile:
	self.hp_max = hp_max;
	self.hp = clamp(self.hp, 0, self.hp_max)
	return self

func duplicate() -> Tile:
	var new_tile = Tile.new()
	new_tile.hp = self.hp
	new_tile.hp_max = self.hp_max
	return new_tile
