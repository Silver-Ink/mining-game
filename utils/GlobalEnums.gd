class_name GE

enum Direction{
	North,
	East,
	South,
	West
}

enum Layer 
{
	BACKGROUND = -100,
	TREASURE = 100,
	FOREGROUND = 200,
	#FOREGROUND = 50, # For debugging
}

enum Tools 
{
	Pickaxe,
	Hammer,
}

enum ShapeName 
{
	Unknow = 0,

	Bg,
	Rock,
	Leaf,
	Sand,
	Bone,
	

	Bracelet,
	BatTalisman,
	Boomerang,
	Diamound,
	Snake,
	GluedStone,
	HorshoeCrab,
	PeruKnife,
	RedGem,
	RomanRuler,
	Ruby,
	Shell,
	SkaraBrae,
	SkullSaber,
	TenonHead,
	Trex
}

const ShapeNameTreasure : Array[ShapeName] = [
	ShapeName.Bracelet,
	ShapeName.BatTalisman,
	ShapeName.Boomerang,
	ShapeName.Diamound,
	ShapeName.Snake,
	ShapeName.GluedStone,
	ShapeName.HorshoeCrab,
	ShapeName.PeruKnife,
	ShapeName.RedGem,
	ShapeName.RomanRuler,
	ShapeName.Ruby,
	ShapeName.Shell,
	ShapeName.SkaraBrae,
	ShapeName.SkullSaber,
	ShapeName.TenonHead,
	ShapeName.Trex
]

# Non Rectangle size
const ShapeNameTreasureInterestingShape : Array[ShapeName] = [
	ShapeName.Bracelet,
	ShapeName.Snake,
	ShapeName.GluedStone,
	ShapeName.RomanRuler,
	ShapeName.Trex
]
