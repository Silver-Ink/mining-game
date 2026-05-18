extends TileMapLayer
class_name WallTileMapLayer

func test_wall_at(global_pos : Vector2) -> bool:
	var map_pos := local_to_map(to_local(global_pos))
	var tile := get_cell_tile_data(map_pos)
	# null if no tile at position
	return tile != null
