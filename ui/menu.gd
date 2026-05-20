extends Control

func _ready() -> void:
	_on_button_button_down()
	
func _on_button_button_down() -> void:
	LevelManager.start_game(_destructor)
	
func _destructor() -> void:
	self.queue_free()
