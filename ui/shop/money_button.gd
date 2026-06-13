extends PanelContainer
class_name MoneyButton

signal button_pressed

@onready var label: Label = $HBoxContainer/Label

var price := 0 :
	set(value):
		if (!is_node_ready()):
			await ready
		price = value
		label.text = str(price)

func _on_button_button_down() -> void:
	button_pressed.emit()
