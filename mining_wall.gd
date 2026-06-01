class_name MiningWall
extends Interractible

@export var variant : MiningWallVariant:
	set(value):
		variant = value
		match value:
			MiningWallVariant.Sparkle:
				pass
			MiningWallVariant.Emerald:
				pass
			MiningWallVariant.Sapphire:
				pass
			MiningWallVariant.BlackStone:
				pass
			MiningWallVariant.Light:
				pass
			MiningWallVariant.Spheres:
				pass
				
@export var facing : GE.Direction :
	set(value):
		facing = value
		match value:
			GE.Direction.North:
				rotation = PI
			GE.Direction.East:
				rotation = PI / 2.
			GE.Direction.South:
				rotation = 0
			GE.Direction.West:
				rotation = 3.* PI / 2.
	
enum MiningWallVariant{
	Sparkle,
	Emerald,
	Sapphire,
	BlackStone,
	Light,
	Spheres
}

@onready var sprite: Sprite2D = %Sprite

func interract(caller : Character):
	print("hello")
