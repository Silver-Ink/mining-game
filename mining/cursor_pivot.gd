extends Node2D
@onready var pivot: Node2D = $Pivot

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

func _process(delta: float) -> void:
	var mouse_dir := get_local_mouse_position()
	pivot.rotation = _get_quadran(atan2(mouse_dir.y, mouse_dir.x))
	#print(atan2(mouse_dir.y, mouse_dir.x))
