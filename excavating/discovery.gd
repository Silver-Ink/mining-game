class_name Discovery extends Area2D

var discovered := false 
var covering_tiles : Array[rock_tile]
var nb_covering_tiles := 0

@onready var sprite: Sprite2D = %sprite

func _ready() -> void:
	#sprite.z_index = 30 # temp
	pass

func _on_area_entered(area: Area2D) -> void:
	if (area is rock_tile):
		if (!covering_tiles.has(area)):
			covering_tiles.append(area)
			nb_covering_tiles += 1
			area.digged.connect(_on_covering_tile_digged)

func _on_covering_tile_digged(tile : rock_tile):
	if (tile._surface_level == sprite.z_index -1):
		nb_covering_tiles -= 1
		if (nb_covering_tiles <= 0):
			sprite.modulate = Color.BLACK
		
