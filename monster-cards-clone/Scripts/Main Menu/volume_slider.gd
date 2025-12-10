extends HSlider

@export
var bus_name: String

var bus_index: int
var value_label: Label

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	
	var parent = get_parent()
	var slider_index = get_index()
	value_label = parent.get_child(slider_index + 1) as Label # assumes value label is the next sibling after the slider
	
	value = db_to_linear(
		AudioServer.get_bus_volume_db(bus_index)
	)
	
	update_label(value)


func _on_value_changed(new_value: float) -> void:
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(new_value)
	)
	update_label(new_value)


func update_label(vol: float) -> void:
	if value_label:
		var percentage = int(vol * 100)
		value_label.text = str(percentage)
