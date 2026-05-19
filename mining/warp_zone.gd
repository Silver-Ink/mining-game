#@tool
extends Area2D
class_name WarpZone

@export var variant : WarpVariant:
	set(value):
		variant = value
		match value:
			WarpVariant.Ladder:
				pass
			WarpVariant.Hole:
				pass
	
enum WarpVariant{
	Ladder,
	Hole
}
