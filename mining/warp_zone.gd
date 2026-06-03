#@tool
extends Area2D
class_name WarpZone

@export var dest_level : SceneManager.SceneId
@export var dest_warp_id : int
@export var self_id : int

@export var variant : WarpVariant:
	set(value):
		variant = value
		match value:
			WarpVariant.Ladder:
				pass
			WarpVariant.Hole:
				pass
	
enum WarpVariant{
	Ladder,
	Hole
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
