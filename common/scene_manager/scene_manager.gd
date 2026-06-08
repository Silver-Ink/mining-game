extends Node

enum SceneId{
	Hub,
	ShopLevel,
	Shop,
	Excavate,
	#Pause,
}

const SCENE_PACKED_SCENES : Dictionary[SceneId, String] = {
	SceneId.Hub : "res://mining/levels/hub.tscn",
	SceneId.ShopLevel : "res://mining/levels/shop.tscn",
	SceneId.Shop : "res://ui/shop.tscn",
	SceneId.Excavate : "res://excavating/excavating_game.tscn"
}

var context : SceneContext

var _scenes_instances : Dictionary[SceneId, Scene]
var _scene_stack : Array[Scene]

func _ready() -> void:
	context = SceneContext.new()

func push_scene(scene_id : SceneId, settings : SceneSettings) -> void:
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
		previous_scene.on_paused()
		
	_add_to_tree(new_scene)
	_scene_stack.append(new_scene)
	
	if (!new_scene.is_node_ready()):
		await new_scene.ready
	new_scene.on_pushed(context, settings)
		
	
func pop_scene(switch_mode := false) -> void:
	var removed_scene : Scene = _scene_stack.pop_back()
	if (removed_scene.do_keep_alive()):
		_remove_from_tree(removed_scene)
		removed_scene.on_popped()
	else:
		removed_scene.queue_free()
		
	var unshelved_scene = current_scene()
	if (unshelved_scene):
		if (!unshelved_scene.is_inside_tree()):
			_add_to_tree(unshelved_scene)
		if (!switch_mode):
			unshelved_scene.on_resumed()
		
func switch_scene(scene_id : SceneId, settings : SceneSettings) -> void:
	pop_scene()
	push_scene(scene_id, settings)
	
func current_scene() -> Scene:
	if (_scene_stack.size() < 1):
		return null
	return _scene_stack[-1]
	
func _add_to_tree(scene : Scene) -> void:
	get_tree().root.add_child.call_deferred(scene)
	
func _remove_from_tree(scene : Scene) -> void:
	scene.get_parent().remove_child(scene)
	
