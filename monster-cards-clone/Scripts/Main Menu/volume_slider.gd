extends HBoxContainer

@export var bus_name: String

@onready var bus_label: Label = $BusLabel
@onready var slider: HSlider = $HSlider
@onready var value_label: Label = $ValueLabel


func _ready() -> void:
	bus_label.text = bus_name
	slider.value = AudioManager.get_volume(bus_name)
	value_label.text = str(int(slider.value))
	


func _on_slider_value_changed(value: float) -> void:
	AudioManager.set_volume(bus_name, int(value))
	value_label.text = str(int(value))


func _on_slider_drag_ended(_value_changed: bool) -> void:
	AudioManager.save_volume()
