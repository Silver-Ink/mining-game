class_name MiningWall
extends Interractible

@export var variant : MiningWallVariant:
	set(value):
		variant = value
		match value:
			MiningWallVariant.Ladder:
				pass
			MiningWallVariant.Hole:
				pass
	
enum MiningWallVariant{
	Ladder,
	Hole
}

func interract(caller : Character):
	print("hello")
