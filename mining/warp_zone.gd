@tool
extends Area2D
class_name WarpZone

@export var dest_level : SceneManager.SceneId
@export var dest_warp_id : int
@export var self_id : int

@export var variant : WarpVariant:
	set(value):
		variant = value
		if (not is_node_ready()):
			await ready
		sprite.texture = _variant_sprites[value]
				
@onready var sprite: Sprite2D = %Sprite

static var _variant_sprites : Dictionary[WarpVariant, Texture2D] = {
	WarpVariant.LadderUp:		load("uid://cf17simlckrfa"),
	WarpVariant.LadderDown:		load("uid://c8k5royrfs14d"),
}
enum WarpVariant{
	LadderUp,
	LadderDown
}

var _contains_character := false

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func receive_character(character : Character):
	_contains_character = true
	character.position = position
	
func _on_area_entered(area : Area2D):
	if (area is Character && !_contains_character):
		area.step_completed.connect(_on_character_steped_in)
		
func _on_area_exited(area : Area2D):
	if (area is Character):
		_contains_character = false
		
func _on_character_steped_in(character : Character):
	SceneManager.switch_scene(dest_level, MiningLevel.MiningLevelSceneSettings.new(dest_warp_id))
	character.step_completed.disconnect(_on_character_steped_in)
