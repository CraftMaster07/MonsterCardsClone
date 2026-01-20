extends VBoxContainer

# Define which buses to create controls for
@export var buses: Array[String] = ["Master", "Sound", "Music"]

# Store references if needed later
var sliders: Dictionary = {}
var value_labels: Dictionary = {}


func _ready() -> void:
	create_volume_controls()


func create_volume_controls() -> void:
	for bus_name in buses:
		var bus_index = AudioServer.get_bus_index(bus_name)
		if bus_index == -1:
			push_warning("Audio bus '" + bus_name + "' not found, skipping")
			continue
		
		# Create container for this bus
		var container = HBoxContainer.new()
		container.name = bus_name + "Container"
		container.size_flags_vertical = Control.SIZE_EXPAND_FILL
		add_child(container)
		
		# Create bus name label
		var name_label = Label.new()
		name_label.text = bus_name
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.size_flags_stretch_ratio = 1
		container.add_child(name_label)
		
		# Create slider
		var slider = HSlider.new()
		slider.min_value = 0
		slider.max_value = 130
		slider.step = 1
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		slider.size_flags_stretch_ratio = 4
		container.add_child(slider)
		
		# Create value label
		var value_label = Label.new()
		value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		value_label.size_flags_stretch_ratio = 0.6
		container.add_child(value_label)
		
		# Store references
		sliders[bus_name] = slider
		value_labels[bus_name] = value_label
		
		# Load saved volume
		slider.value = AudioManager.get_volume(bus_name)
		value_label.text = str(int(slider.value))
		
		slider.value_changed.connect(_on_slider_changed.bind(bus_name, value_label))

func _on_slider_changed(new_value: float, bus_name: String, label: Label) -> void:
	AudioManager.set_volume(bus_name, int(new_value))
	label.text = str(int(new_value))
