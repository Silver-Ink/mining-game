extends MiningArea

@onready var spawn_point: Marker2D = $SpawnPoint

func set_as_current_level(character : Character) -> void:
	super.set_as_current_level(character)
	character.position = spawn_point.position
