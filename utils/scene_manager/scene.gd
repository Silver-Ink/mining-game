extends Node
class_name Scene


# If true, the scene instance won't be freed when popped from the scene stack
func do_keep_alive() -> bool:
	return false
	
# If fasle, previous scene will remains in the tree (but paused) when this one is pushed.
# Usefull for a pause screen when you want to see the game behind it.
func do_untree_previous_scene() -> bool:
	return true

# Called when the scene is popped from the scene stack (in scene_manager)
# or when another scene get placed directly above in the stack
func pause() -> void:
	pass

# Called when the scene is pushed on the scene stack (in scene_manager)
# or when it becomes the topmost one
func resume(_context : SceneContext, _settings : SceneSettings) -> void:
	pass
	# DEFAULT CODE with T extends SceneManager.SceneSettings
	
	#if (settings is --T-- ):
		# --LOGIC HERE--
	#else: 
		#push_error(SceneManager.push_scene.get_method(), " was called with an incorrect SceneSettings type, expected : --T-- \n",\
					#Engine.capture_script_backtraces())
