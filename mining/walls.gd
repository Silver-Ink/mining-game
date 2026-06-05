extends TileMapLayer
class_name WallTileMapLayer

var _cell_data : Dictionary[Vector2i, CellData]
@onready var wall_cracks: TileMapLayer = %WallCracks

const DIGGABLE_STRING = "diggable"

class CellData:
	var breaking : float = 1.

func test_wall_at(global_pos : Vector2) -> bool:
	var tile := _get_tile_data_at(global_pos)
	# null if no tile at position
	return tile != null

func dig_at(global_pos : Vector2, damage : float) -> void:
	assert(damage > 0)
	var tile := _get_tile_data_at(global_pos)
	if (tile == null):
		return
	if (!tile.has_custom_data(DIGGABLE_STRING)):
		return
		
	var diggable : bool = tile.get_custom_data(DIGGABLE_STRING)
	if (!diggable):
		return 

	var pos = local_to_map(to_local(global_pos))
	var data : CellData = _cell_data.get_or_add(pos, CellData.new())
	data.breaking -= damage
	_set_crack_tile(pos, data.breaking)
	if (data.breaking <= 0):
		BetterTerrain.set_cell(self, pos, -1)
		BetterTerrain.update_terrain_cell(self, pos)
		_cell_data.erase(pos)
		
	# TODO : Add particles

func _set_crack_tile(pos : Vector2i, breaking : float):
	if (breaking <= 0):
		wall_cracks.set_cell(pos)
		return
	var atlas : TileSetAtlasSource =wall_cracks.tile_set.get_source(1)
	var size : Vector2i = atlas.get_atlas_grid_size()
	var x_tile_pos : int = int((1. - breaking) * size.x)
	wall_cracks.set_cell(pos, 1, Vector2i(x_tile_pos, 0))

func _get_tile_data_at(global_pos : Vector2) -> TileData:
	return get_cell_tile_data(local_to_map(to_local(global_pos)))

	
	
