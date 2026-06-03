extends Node

enum SceneId{
	LevelA, LevelB,
	#Shop,
	Excavate,
	#Pause,
}

const CHARACTER = preload("uid://dyfcv20bbelti")

const SCENE_PACKED_SCENES : Dictionary[SceneId, String] = {
	SceneId.LevelA : "res://mining/levels/hub.tscn",
	SceneId.LevelB : "res://mining/levels/test.tscn",
	
	SceneId.Excavate : "res://excavating/excavating_game.tscn"
}

var context : Dictionary = {}

var _scenes_instances : Dictionary[SceneId, Scene]
var _scene_stack : Array[Scene]

func _ready() -> void:
	context["character"] = CHARACTER.instantiate()

func push_scene(scene_id : SceneId) -> void:
	var new_scene : Scene
	if (!_scenes_instances.keys().has(scene_id)):
		var packed_scene : PackedScene = load(SCENE_PACKED_SCENES[scene_id])
		new_scene = packed_scene.instantiate()
		if (new_scene.do_keep_alive()):
			_scenes_instances[scene_id] = new_scene
	else:
		new_scene = _scenes_instances[scene_id]
		
	var previous_scene = current_scene()
	if (previous_scene):
		if (new_scene.do_untree_previous_scene()):
			_remove_from_tree(previous_scene)
			#if (!previous_scene.do_keep_alive()):
				#previous_scene.queue_free()
		
		previous_scene.pause()
		
	_add_to_tree(new_scene)
	_scene_stack.append(new_scene)
	
	if (!new_scene.is_node_ready()):
		await new_scene.ready
	new_scene.resume(context)
		
	
func pop_scene() -> void:
	var removed_scene : Scene = _scene_stack.pop_back()
	_remove_from_tree(removed_scene)
	
	
	var unshelved_scene = current_scene()
	if (unshelved_scene && !unshelved_scene.is_inside_tree()):
		_add_to_tree(unshelved_scene)
		
func switch_scene(scene_id : SceneId) -> void:
	pop_scene()
	push_scene(scene_id)
	
func current_scene() -> Scene:
	if (_scene_stack.size() < 1):
		return null
	return _scene_stack[-1]
	
func _add_to_tree(scene : Scene) -> void:
	get_tree().root.add_child.call_deferred(scene)
	
func _remove_from_tree(scene : Scene) -> void:
	scene.get_parent().remove_child(scene)
	
