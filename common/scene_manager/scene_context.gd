class_name SceneContext

# Contains all instances shared between all scenes 
# (common part of the scene's context)

const CHARACTER = preload("uid://dyfcv20bbelti")
const INVENTORY = preload("uid://dqvajh1fstmrd")

var character : Character
var inventory : Inventory

func _init():
	character = CHARACTER.instantiate()
	inventory = INVENTORY.new()
