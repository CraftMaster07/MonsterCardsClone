extends Control


@onready var _lines: Node2D = $Line2D

var _pressed: bool = false
var _current_line: Line2D

var color: Color = Color(1, 1, 1)
var width: float = 5


func update_color(new_color: Color) -> void:
	color = new_color


func update_width(new_width: float) -> void:
	width = new_width


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_pressed = event.pressed

			if _pressed:
				_current_line = Line2D.new()
				_current_line.default_color = color
				_current_line.width = width
				_lines.add_child(_current_line)
				_current_line.add_point(event.position)

	elif _pressed and event is InputEventMouseMotion:
		_current_line.add_point(event.position)


func _on_area_2d_mouse_exited() -> void:
	_pressed = false
