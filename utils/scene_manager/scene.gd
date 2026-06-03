extends Node
class_name Scene


func do_keep_alive() -> bool:
	return false
	
func do_untree_previous_scene() -> bool:
	return true

func pause() -> void:
	pass

func resume(context : SceneContext, settings : SceneSettings) -> void:
	pass
	# DEFAULT CODE with T extends SceneManager.SceneSettings
	
	#if (settings is --T-- ):
		# --LOGIC HERE--
	#else: 
		#push_error(SceneManager.push_scene.get_method(), " was called with an incorrect SceneSettings type, expected : --T-- \n",\
					#Engine.capture_script_backtraces())
