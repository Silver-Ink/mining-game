#extends Resource
extends Node
class_name GameAsset

var SPRITE_ROCK_BACKGROUND_TEXTURE = preload("uid://cn7250215l36p")
var SPRITE_ROCK_TEXTURE = preload("uid://cgx2owg5pg03n")

var sprite_rock_background = SPRITE_ROCK_BACKGROUND_TEXTURE.instantiate()
var sprite_rock = SPRITE_ROCK_TEXTURE.instantiate()

func _init() -> void:
	pass
