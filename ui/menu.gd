extends Control

func _ready() -> void:
	_on_button_button_down() #TEMP skip the menu on start
	
func _on_button_button_down() -> void:
	SceneManager.push_scene(SceneManager.SceneId.Hub, MiningLevel.MiningLevelSceneSettings.new(-1))
	self.queue_free()
	
