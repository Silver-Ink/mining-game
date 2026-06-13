extends Panel
class_name MoneyPanel
@onready var label: Label = $MarginContainer/HBoxContainer/Label

func init(context : SceneContext):
	label.text = str(context.inventory.money)
