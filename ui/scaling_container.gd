@tool
class_name ScalableTextureRect
extends Container

var texture_rect : TextureRect

@export var texture : Texture2D :
	set(value):
		texture = value
		if (!is_node_ready()):
			await ready
		
		if (!is_instance_valid(texture_rect)):
			texture_rect = TextureRect.new()
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(texture_rect)
			
		texture_rect.texture = texture
		
# inspired from https://github.com/godotengine/godot-proposals/discussions/11471

@export var content_scale := 1.5:
	set(v):
		content_scale = v
		queue_sort()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_SORT_CHILDREN:
			for child:Control in get_children():
				child.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT,Control.PRESET_MODE_MINSIZE)
				child.set_deferred("size", size / content_scale)
				child.scale = Vector2(content_scale,content_scale)
