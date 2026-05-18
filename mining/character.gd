extends Area2D

var tile_edge : int
@onready var step_timer: Timer = $StepTimer

var _can_step := true
var _last_direction : Vector2i

func _ready() -> void:
	# watch if id ref creates conflicts with vcs
	tile_edge = load("uid://c50wvgvfyx2fk").tile_size.x # Assuming we have square tiles
	
	step_timer.timeout.connect(_on_step_timer_end)

func _process(_delta: float) -> void:
	_step()


func _step() -> void:
	if (!_can_step):
		return
	
	var input := Vector2i(int(Input.get_axis("ui_left", "ui_right")), \
							  int(Input.get_axis("ui_up", "ui_down"))) 
	var direction : Vector2i
	
	if (_is_input_orthogonal(input)):
		direction = input
		_move(direction)
		_last_direction = direction
	elif (input != Vector2i.ZERO):
		direction = input - _last_direction
		if (_last_direction == Vector2i.ZERO):
			# prevent two keys pressed at the same time, making moving diagonaly
			direction.y = 0 
		_move(direction)
	else:
		_last_direction = Vector2i.ZERO

func _move(movement : Vector2i) -> void:
	position += Vector2(movement) * tile_edge
	_can_step = false
	step_timer.start()
	
func _is_input_orthogonal(movement : Vector2i) -> bool:
	return abs(movement.x + movement.y) == 1
	
func _on_step_timer_end():
	_can_step = true
	
	
