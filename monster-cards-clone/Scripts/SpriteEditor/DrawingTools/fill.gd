class_name Fill
extends DrawingTool


var width: float


func _init(new_canvas: Node2D, new_color: Color, new_width: float) -> void:
	canvas = new_canvas
	color = new_color
	width = new_width


func set_width(new_width: float) -> void:
	width = new_width


func on_press(pos: Vector2) -> void:
	init_line()
	_line.add_point(pos)


func init_line():
	_line = Line2D.new()
	_line.default_color = color
	_line.width = width
	canvas.add_child(_line)


func on_drag(pos: Vector2) -> void:
	if _line:
		_line.add_point(pos)


func on_release(_pos: Vector2) -> void:
	_line = null


func on_canvas_entrance() -> void:
	init_line()
