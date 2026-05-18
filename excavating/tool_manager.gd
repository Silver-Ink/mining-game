class_name tool_manager extends Node

enum tool{
	none, pickaxe, hammer
}

signal tool_used(t: tool)

var cursor_icons = [
	preload("res://assets/tools/pickaxe.png"),
	preload("res://assets/tools/hammer.png")
]
var tool_dig_previews := {
	tool.pickaxe : preload("res://assets/tools/pickaxe_preview.png"),
	tool.hammer : preload("res://assets/tools/hammer_preview.png"),
}
var _are_tools_blocked = true

var _current_tool = tool.none

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func init_excavation() -> void:
	change_tool(tool.pickaxe)
	_are_tools_blocked = false
	
func end_excavation() -> void:
	_are_tools_blocked = true

func change_tool(t: tool)->void:
	_current_tool = t
	var cursor
	match _current_tool:
		tool.pickaxe:
			cursor = cursor_icons[0]
		tool.hammer:
			cursor = cursor_icons[1]
			
	CustomCursor.set_icon(cursor)
	
func use_tool(ea: ExcavateArea, pos: Vector2i) -> void:
	if (_are_tools_blocked):
		return
	match _current_tool:
		tool.pickaxe:
			_try_dig_at(ea, pos, 0, 0)
			_try_dig_at(ea, pos, 1, 0)
			_try_dig_at(ea, pos, -1, 0)
			_try_dig_at(ea, pos, 0, 1)
			_try_dig_at(ea, pos, 0, -1)
			
		tool.hammer:
			_try_dig_at(ea, pos, -1, -1)
			_try_dig_at(ea, pos, -1, 0)
			_try_dig_at(ea, pos, -1, 1)
			
			_try_dig_at(ea, pos, 0, -1)
			_try_dig_at(ea, pos, 0, 0)
			_try_dig_at(ea, pos, 0, 1)
			
			_try_dig_at(ea, pos, 1, -1)
			_try_dig_at(ea, pos, 1, 0)
			_try_dig_at(ea, pos, 1, 1)
		tool.none:
			return
	tool_used.emit(_current_tool)
			
func _try_dig_at(ea: ExcavateArea, pos: Vector2i, offset_x: int, offset_y: int) -> void:
	var tile = ea.get_tile_vec(pos + Vector2i(offset_x, offset_y), true)
	if (tile != null):
		tile.dig()
	
func get_tool_dig_preview() -> Texture2D:
	if (tool_dig_previews.has(_current_tool)):
		return tool_dig_previews[_current_tool]
	return null
