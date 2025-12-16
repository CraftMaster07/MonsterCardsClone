extends HSlider

@export var bus_name: String

var bus_index: int
var value_label: Label

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		push_error("Audio bus '" + bus_name + "' not found")
		return

	min_value = 0
	max_value = 130
	step = 1
	
	value_changed.connect(_on_value_changed)
	
	var parent = get_parent()
	var slider_index = get_index()
	# assumes value label is the next sibling after the slider
	value_label = parent.get_child(slider_index + 1) as Label
	
	value = AudioManager.get_volume(bus_name)
	update_label(value)
	
	update_label(value)


func _on_value_changed(new_value: float) -> void:
	AudioManager.set_volume(bus_name, int(new_value))
	update_label(new_value)


func update_label(vol: float) -> void:
	if value_label:
		value_label.text = str(int(vol))
