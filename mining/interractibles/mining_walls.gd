extends Node2D

@export var walls_tile_map : WallTileMapLayer

func _ready() -> void:
	for c in get_children():
		if (c is MiningWall):
			walls_tile_map.register_mining_wall(c)
