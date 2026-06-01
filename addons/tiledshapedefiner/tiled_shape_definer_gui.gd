@tool
extends Control
class_name TiledShapeDefinerGui

signal gui_resource_changed(tiles : Tiles)

@onready var grid_container: GridContainer = %GridContainer
@onready var spin_box_x: SpinBox = %SpinBoxX
@onready var spin_box_y: SpinBox = %SpinBoxY

@onready var none_button: Button = $BottomPart/VBoxContainer/MarginContainer2/NoneButton
@onready var all_button: Button = $BottomPart/VBoxContainer/MarginContainer/AllButton

var checkboxes : Array[CheckBox]
var x = 2
var y = 2

var _initilized := false

func get_focusable_elements() -> Array[Control]:
	var elements : Array[Control]
	for el in checkboxes:
		elements.append(el as Control)
	elements.append_array([spin_box_x, spin_box_y])
	elements.append_array([all_button, none_button])
	return elements
	
func set_from_resource(tiles : Tiles) -> void:
	if (_initilized):
		return
	_initilized = true
	if (tiles.tiles().is_empty()):
		return

	var bb = tiles.bounding_box().size
	var offset = tiles.bounding_box().position
	x = bb.x
	spin_box_x.value = x
	y = bb.y
	spin_box_y.value = y
	grid_container.columns = x
	print("_update_property")
	_update_checkboxes(false)
	
	for tile in tiles.tiles():
		var pos = tile - offset
		var index = pos.y * x + pos.x
		if (index >= checkboxes.size()):
			push_error("error while importing tiles : no checkbox at x: ", pos.x, " y: ", pos.y)
			return
		checkboxes[index].set_pressed_no_signal(true)
	
func _ready() -> void:
	_update_checkboxes()
	spin_box_x.value = x
	spin_box_y.value = y
	
func _update_checkboxes(export := true) -> void:
	print("_update_checkboxes ", x, " ", y)
	checkboxes.clear()
	for n in grid_container.get_children():
		grid_container.remove_child(n)
		n.queue_free() 
	for i in range(x * y):
		var checkbox = CheckBox.new()
		grid_container.add_child(checkbox)
		checkbox.toggled.connect(_on_any_checkbox_toggled)
		checkboxes.append(checkbox)
	if (export):
		_export_shape()

func _export_shape() -> void:
	var tiles = Tiles.new()
	var positions : Array[Vector2i]
	for i in range(x):
		for j in range(y):
			var index = j*x + i
			if (index >= checkboxes.size()):
				push_error("error while exporting tiles : no checkbox at x: ", i, " y: ", j)
				return
			var cb = checkboxes[index]
			if (cb.button_pressed):
				positions.append(Vector2i(i, j))
	print(positions)
	tiles.add_all(positions)
	gui_resource_changed.emit(tiles)
	
func _on_none_button_button_down() -> void:
	for cb in checkboxes:
		cb.set_pressed_no_signal(false)
	_export_shape()

func _on_all_button_button_down() -> void:
	for cb in checkboxes:
		cb.set_pressed_no_signal(true)
	_export_shape()
	
func _on_spin_box_x_value_changed(value: float) -> void:
	x = value
	grid_container.columns = value
	_update_checkboxes()

func _on_spin_box_y_value_changed(value: float) -> void:
	y = value
	_update_checkboxes()

func _on_any_checkbox_toggled(toggled : bool) -> void:
	_export_shape()
