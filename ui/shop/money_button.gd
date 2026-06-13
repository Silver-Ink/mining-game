extends PanelContainer

signal button_pressed

func _on_button_button_down() -> void:
	button_pressed.emit()
