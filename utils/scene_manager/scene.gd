extends Node
class_name Scene


func do_keep_alive() -> bool:
	return false
	
func do_untree_previous_scene() -> bool:
	return true

func pause() -> void:
	pass

func resume(context : Dictionary) -> void:
	pass
