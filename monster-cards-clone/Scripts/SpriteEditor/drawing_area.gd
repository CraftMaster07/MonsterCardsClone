extends Control


@export var card_image: CardImage
var _undo_stack: Array

var _pressed: bool = false
var _tool: DrawingTool

var color: Color = Color.WHITE
var width: float = 5


func _ready() -> void:
	set_pen()


func use_tool(tool: DrawingTool) -> void:
	_tool = tool


func update_color(new_color: Color) -> void:
	color = new_color

	if _tool:
		_tool.set_color(color)


func update_width(new_width: float) -> void:
	width = new_width

	if _tool and _tool.has_method("set_width"):
		_tool.width = width


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not _tool: return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_pressed = event.pressed

			if _pressed:
				_tool.on_press(event.position)
			else:
				_tool.on_release(event.position)

	elif _pressed and event is InputEventMouseMotion:
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if _pressed:
				_pressed = false
				_tool.on_release(event.position)
			return

		_tool.on_drag(event.position)


func _on_area_2d_mouse_entered() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_pressed = true
		_tool.on_press(get_global_mouse_position())


func undo() -> void:
	var child = card_image.pop_line()
	if not child: return
	child.visible = false
	_undo_stack.append(child)


func redo() -> void:
	if not _undo_stack.size(): return
	var child = _undo_stack.pop_back()
	card_image.add_line(child)
	child.visible = true


func set_pen() -> void:
	use_tool(Pen.new(card_image, color, width))


# func set_fill() -> void:
# 	use_tool(Fill.new(card_image, color))


func get_serialized_card_image() -> Dictionary:
	return card_image.serialize()


func load_serialized_card_image(data: Dictionary) -> void:
	card_image.deserialize(data)


func clear_undo_stack() -> void:
	_undo_stack.clear()