extends Node2D
class_name ExcavatingGame

var areas : Array[GameArea] = []

var area_active : GameArea = null:
	get:
		return area_active
	set(value):
		if not value in areas and value != null:
			areas.append(value)
		
		if area_active != null:
			area_active.leave()
			remove_child(area_active)
		
		area_active = value
		if area_active != null:
			area_active.enter()
			add_child(area_active)
		update_camera()


@onready var camera: Camera2D = $camera
var asset : GameAsset = GameAsset.new()

func _on_window_resized():
	# Use call_deferred to avoid layout issues
	call_deferred("update_camera")

func _ready() -> void:
	var layout = GameAreaLayout.default();
	area_active = layout.generate()
	update_camera()
	get_tree().root.connect("size_changed", update_camera)
	
func update_camera():
	if area_active != null:
		area_active.update_camera(self.camera, get_viewport())


func _process(delta: float) -> void:
	pass
	
