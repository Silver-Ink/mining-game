extends Scene
class_name ExcavatingGame

var area_active : GameArea = null:
	get:
		return area_active
	set(value):		
		if area_active != null:
			area_active.leave()
			remove_child(area_active)
		
		area_active = value
		if area_active != null:
			area_active.enter()
			add_child(area_active)
		update_camera()


var max_dig = 8
var nb_dig = 0

func finish_digging() -> bool:
	return self.nb_dig >= self.max_dig

func collected_treasure() -> Array[Shape]:
	return self.area_active.collected_treasure()

@onready var camera: Camera2D = $camera
var asset : GameAsset = GameAsset.new()

func _on_window_resized():
	# Use call_deferred to avoid layout issues
	call_deferred("update_camera")

func _ready() -> void:
	var layout = GameAreaLayout.default();
	area_active = layout.instanciate()
	update_camera()
	get_tree().root.connect("size_changed", update_camera)
	
class ExcavatingGameSceneSettings extends SceneSettings:
	var test : String
	func _init(t : String):
		test = t

func on_pushed(context : SceneContext, settings : SceneSettings) -> void:
	if (settings is ExcavatingGameSceneSettings):
		print(settings.test)
	else: 
		push_error(SceneManager.push_scene.get_method(), " was called with an incorrect SceneSettings type, expected : ExcavatingGameSceneSettings \n",\
					Engine.capture_script_backtraces())

func update_camera():
	if area_active != null:
		area_active.update_camera(self.camera, get_viewport())

# TEMP : way to exit the scene
func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action("ui_cancel")):
		SceneManager.pop_scene()
	if (event.is_action_pressed("use_tool") && area_active):
		if self.nb_dig < self.max_dig:
			var pos : Vector2i = area_active.mouse_tile_pos()
			area_active.use_tool(GE.Tools.Pickaxe, pos)
			self.nb_dig += 1
			if self.finish_digging():
				# Todo: disable the pickaxe cursor
				CustomCursor.set_icon(Texture2D.new())
				if self.area_active:
					self.area_active.sfx.play("done");
