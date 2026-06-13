extends Panel
class_name MoneyPanel
@onready var label: Label = $MarginContainer/HBoxContainer/Label

func with_data(context : SceneContext) -> MoneyPanel:
	label.text = str(context.inventory.money)
	return self
