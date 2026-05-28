extends EditorProperty
class_name TiledShapeEditorProperty

const TILED_SHAPE_DEFINER_GUI = preload("uid://dgmlu78ciu27x")

var _gui : TiledShapeDefinerGui

func _init() -> void:
	_gui = TILED_SHAPE_DEFINER_GUI.instantiate()
	add_child(_gui)
	_on_gui_ready.call_deferred()
	
func _ready() -> void:
	label = ""
	name_split_ratio = 0.
	_gui.gui_resource_changed.connect(_on_gui_resource_changed)
	
	
func _on_gui_ready() -> void:
	for elem in _gui.get_focusable_elements():
		if elem:
			add_focusable(elem)
		else:
			push_warning("GUI returned a invalid focusable element")

func _update_property() -> void:
	var prop = get_edited_object()[get_edited_property()]
	if (prop is Tiles):
		_gui.set_from_resource(prop)
	
func _on_gui_resource_changed(tiles : Tiles):
	emit_changed(get_edited_property(), tiles)
