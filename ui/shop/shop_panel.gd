extends Panel
class_name  TreasureSelling

@export var children_container : Container
@onready var margin_container: MarginContainer = %MarginContainer
const TREASURE = preload("uid://pox7n7l5qutn")


func _ready() -> void:
	if (is_instance_valid(children_container)):
		children_container.reparent(margin_container, false)
		
func with_data(context : SceneContext) -> TreasureSelling:
	var items := context.inventory.items
	for item : Item in items:
		var treasure : TreasureUI = TREASURE.instantiate().with_data(item)
		children_container.add_child(treasure)
	return self
