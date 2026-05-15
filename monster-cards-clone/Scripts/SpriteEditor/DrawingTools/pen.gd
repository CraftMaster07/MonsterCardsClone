class_name Pen
extends DrawingTool


var width: float
var _line: Line2D


func _init(new_card_image: Node, new_color: Color, new_width: float) -> void:
	card_image = new_card_image
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
	card_image.add_line(_line)


func on_drag(pos: Vector2) -> void:
	if _line:
		_line.add_point(pos)


func on_release(_pos: Vector2) -> void:
	_line = null
