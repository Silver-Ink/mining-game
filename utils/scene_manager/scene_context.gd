class_name SceneContext

const CHARACTER = preload("uid://dyfcv20bbelti")

var character : Character

func _init():
	character = CHARACTER.instantiate()
