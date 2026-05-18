extends Node2D

@onready var walls: WallTileMapLayer = $Walls
@onready var character: Character = $Character


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_bind_references()
	
func _bind_references() -> void:
	character.walls = walls
