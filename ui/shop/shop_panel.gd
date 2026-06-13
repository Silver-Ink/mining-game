extends Panel
class_name  TreasureSelling

@export var children_container : Container
@onready var margin_container: MarginContainer = %MarginContainer
const TREASURE = preload("uid://pox7n7l5qutn")

func _ready() -> void:
	if (is_instance_valid(children_container)):
		children_container.reparent(margin_container, false)
		
func init(context : SceneContext):
	var items = context.inventory.items
	for i in items.keys():
		for n in range(items[i]):
			var treasure = TREASURE.instantiate()
			children_container.add_child(treasure)
			
