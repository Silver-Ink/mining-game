class_name ShopGui
extends Scene

class ShopSettings extends SceneSettings:
	pass


# Called when the scene is popped from the scene stack (in scene_manager)
func on_popped() -> void:
	pass

# Called when the scene is pushed on the scene stack (in scene_manager)
func on_pushed(_context : SceneContext, _settings : SceneSettings) -> void:
	pass

# Called when another scene get placed directly above in the stack
func on_paused() -> void:
	pass

#Called when the scene becomes the top most scene in scene stack
func on_resumed() -> void:
	pass
