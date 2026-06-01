extends EditorInspectorPlugin

func _can_handle(object: Object) -> bool:
	return object is Shape
	
func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint,
		hint_string: String, usage_flags: int, wide: bool) -> bool:
	if (name == "tile"):
		add_property_editor(name, TiledShapeEditorProperty.new())
		return true
	return false
