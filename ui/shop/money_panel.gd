extends Panel
class_name MoneyPanel
@onready var label: Label = $MarginContainer/HBoxContainer/Label

var _context : SceneContext

func with_data(context : SceneContext) -> MoneyPanel:
	_context = context
	return self

func _process(delta: float) -> void:
	label.text = str(_context.inventory.money)
	
