extends Node2D 

@onready var floor_light: PointLight2D = %FloorLight
@onready var wall_light: PointLight2D = %WallLight

var floor_light_base_scale : float
var wall_light_base_scale : float

var flicker_duration := .1
var flicker_range := .03

func _ready() -> void:
	floor_light_base_scale = floor_light.texture_scale
	wall_light_base_scale = wall_light.texture_scale
	
	create_flicker_tween()
	tree_entered.connect(create_flicker_tween)
	
func create_flicker_tween() -> void:
	if (!is_inside_tree()):
		return
	var tween = get_tree().create_tween()
	var flicker_ratio : float = 1. + randf_range(-flicker_range, flicker_range)
	tween.tween_property(floor_light,\
						 "texture_scale",\
						 floor_light_base_scale * flicker_ratio,\
						 flicker_duration)
	tween.set_parallel(true)
	tween.tween_property(wall_light,\
						 "texture_scale",\
						 wall_light_base_scale * flicker_ratio,\
						 flicker_duration)
	tween.set_parallel(false)
	tween.tween_callback(create_flicker_tween)
	
