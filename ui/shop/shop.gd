class_name ShopGui
extends Scene

class ShopSettings extends SceneSettings:
	pass


# Called when the scene is popped from the scene stack (in scene_manager)
func on_popped() -> void:
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED

# Called when the scene is pushed on the scene stack (in scene_manager)
func on_pushed(_context : SceneContext, _settings : SceneSettings) -> void:
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT

# Called when another scene get placed directly above in the stack
func on_paused() -> void:
	pass

#Called when the scene becomes the top most scene in scene stack
func on_resumed() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("ui_cancel")):
		SceneManager.pop_scene()
