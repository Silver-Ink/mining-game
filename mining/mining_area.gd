extends Node2D
class_name MiningArea

@onready var walls: WallTileMapLayer = $Walls

var character_ref : Character

func set_as_current_level(character : Character) -> void:
	character_ref = character
	if (character.get_parent() != null):
		character.reparent(self)
	else:
		add_child(character)
	_bind_references()
	
func _bind_references() -> void:
	character_ref.walls = walls
