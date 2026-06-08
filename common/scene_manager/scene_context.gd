class_name SceneContext

# Contains all instances shared between all scenes 
# (common part of the scene's context)

const CHARACTER = preload("uid://dyfcv20bbelti")

var character : Character

func _init():
	character = CHARACTER.instantiate()
