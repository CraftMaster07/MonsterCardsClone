extends Control


@export var color_picker_button: ColorPickerButton
@export var width_spin_box: SpinBox
@export var drawing_area: Control


func _ready() -> void:
	_on_color_picker_button_color_changed(color_picker_button.color)
	_on_width_spin_box_value_changed(width_spin_box.value)


func _on_color_picker_button_color_changed(color: Color) -> void:
	drawing_area.update_color(color)


func _on_width_spin_box_value_changed(value: float) -> void:
	drawing_area.update_width(value)
