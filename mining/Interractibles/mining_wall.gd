class_name MiningWall
extends Interractible

const BASE_SHAPE_EDGE_SIZE := 8

@export var variant : MiningWallVariant:
	set(value):
		variant = value
		if (not is_node_ready()):
			await ready
		
		sprite.texture = _variant_sprites[value]
		
		var shape := collision_shape.shape
		if (shape is RectangleShape2D):
			shape.size.x = BASE_SHAPE_EDGE_SIZE * _variant_widths[value]
				
@export var facing : GE.Direction = GE.Direction.South :
	set(value):
		facing = value
		match value:
			GE.Direction.North:
				rotation = PI
			GE.Direction.East:
				rotation = 3.* PI / 2.
			GE.Direction.South:
				rotation = 0
			GE.Direction.West:
				rotation = PI / 2.
				
static var _variant_sprites : Dictionary[MiningWallVariant, Texture2D] = {
	MiningWallVariant.Sparkle:		load("uid://m1uq6joqgu48"),
	MiningWallVariant.Emerald:		load("uid://cr5rfi3sif1gv"),
	MiningWallVariant.Sapphire:		load("uid://d4lg8kpn5tbf2"),
	MiningWallVariant.BlackStone: 	load("uid://whqjqfy4ajbc"),
	MiningWallVariant.Light: 		load("uid://obx6g50ciipi"),
	MiningWallVariant.Ruby: 		load("uid://dsoq8mwc4apli"),
	MiningWallVariant.Spheres:		load("uid://5kg0x03te653")
}

static var _variant_widths : Dictionary[MiningWallVariant, int] = {
	MiningWallVariant.Sparkle:		1,
	MiningWallVariant.Emerald:		2,
	MiningWallVariant.Sapphire:		2,
	MiningWallVariant.BlackStone: 	2,
	MiningWallVariant.Light: 		2,
	MiningWallVariant.Ruby: 		2,
	MiningWallVariant.Spheres:		3
}
				
	
enum MiningWallVariant{
	Sparkle,
	Emerald,
	Sapphire,
	BlackStone,
	Light,
	Ruby,
	Spheres
}

@onready var sprite: Sprite2D = %Sprite
@onready var collision_shape: CollisionShape2D = %CollisionShape

func interract(caller : Character):
	print("hello")
