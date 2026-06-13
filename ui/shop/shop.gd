class_name ShopGui
extends Scene

var scale_factor := 2.

class ShopSettings extends SceneSettings:
	pass
@onready var money_panel: MoneyPanel = $MoneyPanel
@onready var treasure_selling: TreasureSelling = $TreasureSelling

func _ready() -> void:
	setup_screen()

# Called when the scene is popped from the scene stack (in scene_manager)
func on_popped() -> void:
	get_tree().root.content_scale_factor = 1.

# Called when the scene is pushed on the scene stack (in scene_manager)
func on_pushed(_context : SceneContext, _settings : SceneSettings) -> void:
	setup_screen()
	money_panel.init(_context)
	treasure_selling.init(_context)

func setup_screen():
	get_tree().root.content_scale_factor = scale_factor

# Called when another scene get placed directly above in the stack
func on_paused() -> void:
	pass

#Called when the scene becomes the top most scene in scene stack
func on_resumed() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("ui_cancel")):
		SceneManager.pop_scene()
			
