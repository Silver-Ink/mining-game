extends Node2D
class_name CursorPivot

@onready var pivot: Node2D = %Pivot
@onready var cursor_area: Area2D = %CursorArea

@export var character : Character

var _contained_interractible : Interractible
func _ready() -> void:
	cursor_area.area_entered.connect(_on_area_entered)
	cursor_area.area_exited.connect(_on_area_exited)

func _get_quadran(fine_angle : float) -> float:
	if (fine_angle < -3 * PI / 4. ):
		return -PI # upper left
	if (fine_angle < -PI / 4. ):
		return -PI/2. # up
	if (fine_angle < PI / 4. ):
		return 0 # right
	if (fine_angle < 3. * PI / 4. ):
		return PI / 2. # down
	return -PI # lower left

func _process(_delta: float) -> void:
	var mouse_dir := get_local_mouse_position()
	pivot.rotation = _get_quadran(atan2(mouse_dir.y, mouse_dir.x))
	
func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("interract") &&\
		_contained_interractible != null):
			_contained_interractible.interract(character)
		
	
func _on_area_entered(area : Area2D):
	if (area is Interractible):
		_contained_interractible = area
		
func _on_area_exited(area : Area2D):
	if (area == _contained_interractible):
		_contained_interractible = null
		
