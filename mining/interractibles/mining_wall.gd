@tool
class_name MiningWall
extends Interractible

@export var variant : MiningWallVariant:
	set(value):
		variant = value
		if (not is_node_ready()):
			await ready
		
		sprite.texture = _variant_sprites[value]

static var _variant_sprites : Dictionary[MiningWallVariant, Texture2D] = {
	MiningWallVariant.Sparkle:		load("uid://m1uq6joqgu48"),
}

	
enum MiningWallVariant{
	Sparkle,
}

@onready var sprite: Sprite2D = %Sprite
@onready var collision_shape: CollisionShape2D = %CollisionShape

func interract(_caller : Character):
	SceneManager.push_scene(SceneManager.SceneId.Excavate, ExcavatingGame.ExcavatingGameSceneSettings.new("Hello World !!"))
	queue_free.call_deferred()
	
func get_central_gposition() -> Vector2:
	return collision_shape.global_position
