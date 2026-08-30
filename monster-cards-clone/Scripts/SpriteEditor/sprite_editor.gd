class_name SpriteEditor
extends Control


@export var color_picker_button: ColorPickerButton
@export var width_spin_box: SpinBox
@export var drawing_area: Control
@export var current_path_label: Label

signal leave

var currnet_card_path: String

func _ready() -> void:
	_on_color_picker_button_color_changed(color_picker_button.color)
	_on_width_spin_box_value_changed(width_spin_box.value)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_undo"):
		drawing_area.undo()
	elif Input.is_action_just_pressed("ui_redo"):
		drawing_area.redo()
	elif Input.is_action_just_pressed("ui_save"):
		_on_quick_save_button_pressed()


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


func _on_save_button_pressed() -> void:
	save()


func save():
	# Define the filters (Extension, then Description)
	var filters = PackedStringArray(["*.json ; Save Data"])
	
	# Open the native dialog
	DisplayServer.file_dialog_show(
		"Select a Card to Save the Sprite to", # Title of the window
		ProjectSettings.globalize_path(PathConstants.CARD_SAVE_PATH), # Initial directory
		"", # Default filename (leave empty for opening)
		false, # Boolean: Show hidden files?
		DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, # Mode (Open File, Save, etc)
		filters, # The filters we defined above
		_on_save_card_file_selected # The function to call when they pick something
	)


func _on_save_card_file_selected(status: bool, selected_paths: PackedStringArray, _selected_filter_index: int):
	if status:
		# status is true if they clicked 'Open', false if they clicked 'Cancel'
		var chosen_path = selected_paths[0]
		print("Load Card selected: ", chosen_path)
		save_image(chosen_path)
	else:
		print("User cancelled the selection.")


func save_image(path: String):
	# saving to a card file should be excluded from the CardData serialize. if it's even a card data? or a card file? idk
	# if it's a card file it's much better.'
	var temp_card_file = CardFile.new()
	temp_card_file.load(path)
	temp_card_file.set_serialized_card_image(drawing_area.get_serialized_card_image())
	temp_card_file.save()

	set_current_card_path(path)


func _on_load_button_pressed() -> void:
	load_card()


func load_card():
	drawing_area.clear_undo_stack()
	# Define the filters (Extension, then Description)
	var filters = PackedStringArray(["*.json ; Save Data"])
	
	# Open the native dialog
	DisplayServer.file_dialog_show(
		"Select a Card to Load the Sprite from", # Title of the window
		ProjectSettings.globalize_path(PathConstants.CARD_SAVE_PATH), # Initial directory
		"", # Default filename (leave empty for opening)
		false, # Boolean: Show hidden files?
		DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, # Mode (Open File, Save, etc)
		filters, # The filters we defined above
		_on_load_card_file_selected # The function to call when they pick something
	)


func _on_load_card_file_selected(status: bool, selected_paths: PackedStringArray, _selected_filter_index: int):
	if status:
		# status is true if they clicked 'Open', false if they clicked 'Cancel'
		var chosen_path = selected_paths[0]
		print("Load Card selected: ", chosen_path)
		load_image(chosen_path)
	else:
		print("User cancelled the selection.")


func load_image(path: String):
	# saving to a card file should be excluded from the CardData serialize. if it's even a card data? or a card file? idk
	# if it's a card file it's much better.'
	var temp_card_file = CardFile.new()
	temp_card_file.load(path)
	drawing_area.load_serialized_card_image(temp_card_file.get_serialized_card_image())

	set_current_card_path(path)


func _on_quick_save_button_pressed() -> void:
	if currnet_card_path == "":
		save()
	else:
		save_image(currnet_card_path)


func set_current_card_path(path: String):
	currnet_card_path = path
	current_path_label.text = "Current Card: " + path


func _on_back_button_pressed() -> void:
	leave.emit()
