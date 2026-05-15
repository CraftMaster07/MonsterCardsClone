extends Control


@export var color_picker_button: ColorPickerButton
@export var width_spin_box: SpinBox
@export var drawing_area: Control


func _ready() -> void:
	_on_color_picker_button_color_changed(color_picker_button.color)
	_on_width_spin_box_value_changed(width_spin_box.value)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_undo"):
		drawing_area.undo()
	elif Input.is_action_just_pressed("ui_redo"):
		drawing_area.redo()


func _on_color_picker_button_color_changed(color: Color) -> void:
	drawing_area.update_color(color)


func _on_width_spin_box_value_changed(value: float) -> void:
	drawing_area.update_width(value)


func _on_undo_button_pressed() -> void:
	drawing_area.undo()


func _on_pen_button_pressed() -> void:
	drawing_area.set_pen()


func _on_redo_button_pressed() -> void:
	drawing_area.redo()


func _on_fill_button_pressed() -> void:
	drawing_area.set_fill()
