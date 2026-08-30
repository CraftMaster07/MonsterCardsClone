class_name Pen
extends DrawingTool


var width: float
var _line: Line2D


func _init(new_sprite: Node, new_color: Color, new_width: float) -> void:
	sprite = new_sprite
	color = new_color
	width = new_width


func set_width(new_width: float) -> void:
	width = new_width


func on_press(pos: Vector2) -> void:
	pos = sprite.to_local_point(pos)
	init_line()
	_line.add_point(pos)


func init_line():
	_line = Line2D.new()
	_line.default_color = color
	_line.width = width / 4
	sprite.add_line(_line)


func on_drag(pos: Vector2) -> void:
	pos = sprite.to_local_point(pos)
	if _line:
		_line.add_point(pos)


func on_release(_pos: Vector2) -> void:
	_line = null
