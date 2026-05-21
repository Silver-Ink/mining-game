extends TileMapLayer
class_name WallTileMapLayer

func test_wall_at(global_pos : Vector2) -> bool:
	var tile := _get_tile_data_at(global_pos)
	# null if no tile at position
	return tile != null

func dig_at(global_pos : Vector2) -> void:
	var tile := _get_tile_data_at(global_pos)
	if (tile == null):
		return
	if (tile.has_custom_data("diggable")):
		var diggable : bool = tile.get_custom_data("diggable")
		if (diggable):
			set_cell(local_to_map(to_local(global_pos)))

func _get_tile_data_at(global_pos : Vector2) -> TileData:
	return get_cell_tile_data(local_to_map(to_local(global_pos)))
	
	
