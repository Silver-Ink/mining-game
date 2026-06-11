extends Panel

@export var children_container : Container
@onready var margin_container: MarginContainer = %MarginContainer

func _ready() -> void:
	if (is_instance_valid(children_container)):
		children_container.reparent(margin_container, false)
