extends Area2D
class_name Character

signal step_completed(character : Character)

const STEP_DURATION := .24

var walls : WallTileMapLayer
@onready var cursor_pivot: CursorPivot = $CursorPivot

var tile_edge : int

var _can_step := true
var _last_direction : Vector2i

func _ready() -> void:
	# watch if id ref creates conflicts with vcs
	tile_edge = load("uid://c50wvgvfyx2fk").tile_size.x # Assuming we have square tiles
	
func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("interract")):
		if (!cursor_pivot.interract()):
			_dig()
			get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	_step()


func _step() -> void:
	if (!_can_step):
		return
	
	var input := Vector2i(int(Input.get_axis("ui_left", "ui_right")), \
							  int(Input.get_axis("ui_up", "ui_down"))) 
	var direction : Vector2i
	
	if (_is_vector_orthonormal(input)):
		direction = input
		_move(direction)
		_last_direction = direction
	elif (input != Vector2i.ZERO):
		direction = input - _last_direction
		if (!_is_vector_orthonormal(direction)):
			if (abs(direction.y) > 1):
				direction = Vector2(0, direction.y / abs(direction.y))
			else:
				direction = Vector2(direction.x / abs(direction.x), 0)
		if (_last_direction == Vector2i.ZERO):
			# prevent two keys pressed at the same time, making moving diagonaly
			direction.y = 0 
		_move(direction)
	else:
		_last_direction = Vector2i.ZERO

func _move(movement : Vector2i) -> void:
	var new_position = position + Vector2(movement) * tile_edge;
	if (walls.test_wall_at(new_position)):
		return
	_can_step = false
	var step_tween = create_tween()
	step_tween.tween_property(self, "position", new_position, STEP_DURATION)
	step_tween.finished.connect(_on_step_timer_end)
	step_tween.play()
	
func _is_vector_orthonormal(movement : Vector2i) -> bool:
	var x : bool = abs(movement.x) == 1
	var y : bool = abs(movement.y) == 1
	return (x || y) && !(x && y) && movement.length() == 1
	
func _on_step_timer_end():
	_can_step = true
	step_completed.emit(self)
	

func _dig():
	var target := cursor_pivot.get_targeted_position()
	walls.dig_at(target)
	
