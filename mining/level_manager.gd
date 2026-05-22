extends Node
enum LevelID {
	Test,
	Hub
}

const CHARACTER = preload("uid://dyfcv20bbelti")

const LEVEL_SCENES : Dictionary[LevelID, String] = {
	LevelID.Test : "res://mining/Levels/test.tscn",
	LevelID.Hub : "res://mining/Levels/hub.tscn"
}	

var character_instance : Character
var level_instances : Dictionary[LevelID, MiningArea] = {}

var current_level : MiningArea

func _ready() -> void:
	character_instance = CHARACTER.instantiate()
	
func start_game(callback : Callable) -> void:
	change_level(LevelManager.LevelID.Hub)
	callback.call()
	
func change_level(level_id : LevelID, warp_id := -1) -> void:
	if (!level_instances.keys().has(level_id)):
		level_instances[level_id] = load(LEVEL_SCENES[level_id]).instantiate()
	
	_change_level_internal.call_deferred(level_id, warp_id)
	
func _change_level_internal(level_id : LevelID, warp_id : int) -> void:
	var parent := _get_current_level_parent()
	if (current_level != null):
		parent.remove_child(current_level)
	current_level = level_instances[level_id]
	parent.add_child(current_level)
	current_level.set_as_current_level(character_instance, warp_id)
	
func _get_current_level_parent() -> Node:
	return get_tree().root
		
