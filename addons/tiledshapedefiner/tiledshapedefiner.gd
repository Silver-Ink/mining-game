@tool
extends EditorPlugin

const EntityInspector = preload("res://addons/tiledshapedefiner/entity_inspector.gd")
var inspector : EntityInspector
func _enter_tree() -> void:
	inspector = EntityInspector.new()
	add_inspector_plugin(inspector)


func _exit_tree() -> void:
	if (inspector):
		remove_inspector_plugin(inspector)
