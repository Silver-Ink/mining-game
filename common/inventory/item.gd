class_name Item

var type : GE.ShapeName
var price : int

const VALUE_VARIATION_RATIO := .1

const treasure_values : Dictionary[GE.ShapeName, int] = {
 	GE.ShapeName.Unknow : 0,

	GE.ShapeName.Bg : 0,
	GE.ShapeName.Rock : 0,
	GE.ShapeName.Leaf : 0,
	GE.ShapeName.Sand : 0,
	GE.ShapeName.Bone : 0,
	GE.ShapeName.Wall : 0,
	

	GE.ShapeName.Bracelet : 200,
	GE.ShapeName.BatTalisman : 100,
	GE.ShapeName.Boomerang : 100,
	GE.ShapeName.Diamound : 100,
	GE.ShapeName.Snake : 100,
	GE.ShapeName.GluedStone : 100,
	GE.ShapeName.HorshoeCrab : 100,
	GE.ShapeName.PeruKnife : 100,
	GE.ShapeName.RedGem : 100,
	GE.ShapeName.RomanRuler : 100,
	GE.ShapeName.Ruby : 100,
	GE.ShapeName.Shell : 100,
	GE.ShapeName.SkaraBrae : 100,
	GE.ShapeName.SkullSaber : 100,
	GE.ShapeName.TenonHead : 100,
	GE.ShapeName.Trex : 100,
	GE.ShapeName.Microwav : 100,
}

func _init(treasure_type : GE.ShapeName) -> void:
	if (!GE.is_treasure(treasure_type)):
		return 

	type = treasure_type
	var init_price = treasure_values[treasure_type]
	var price_variation = init_price * randf_range(-VALUE_VARIATION_RATIO, VALUE_VARIATION_RATIO)
	price = floor(init_price + price_variation)
		
