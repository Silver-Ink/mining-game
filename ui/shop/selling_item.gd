extends PanelContainer

@onready var treasure_lock: PanelContainer = $MarginContainer/TreasureLock
@onready var item_selling: PanelContainer = $MarginContainer/ItemSelling

var has_mouse := false

func _ready() -> void:
	item_selling.visible = false
	
func _on_treasure_lock_mouse_entered() -> void:
	has_mouse = true


func _on_treasure_lock_mouse_exited() -> void:
	has_mouse = false


func _on_treasure_lock_gui_input(event: InputEvent) -> void:
	if (has_mouse && event.is_action_pressed("interract")):
		get_viewport().set_input_as_handled()
		treasure_lock.queue_free()
		item_selling.visible = true


func _on_buy_button_button_pressed() -> void:
	print("$$$")
