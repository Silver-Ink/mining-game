extends Interractible

@export var scene_to_load : SceneManager.SceneId

func interract(caller : Character):
	var settings : SceneSettings = SceneSettings.new()
	SceneManager.push_scene(scene_to_load, settings)
