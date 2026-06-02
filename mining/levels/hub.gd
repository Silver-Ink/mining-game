extends MiningArea

@onready var spawn_point: Marker2D = $SpawnPoint
var _spawned := false

func set_as_current_level(character : Character, warp_id: int) -> void:
	super.set_as_current_level(character, warp_id)
	if (!_spawned):
		character.position = spawn_point.position
		_spawned = true
