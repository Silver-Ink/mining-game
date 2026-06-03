extends Control

func _ready() -> void:
	_on_button_button_down()
	
func _on_button_button_down() -> void:
	SceneManager.push_scene(SceneManager.SceneId.LevelA)
	self.queue_free()
	
