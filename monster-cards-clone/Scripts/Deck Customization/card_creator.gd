class_name CardCreator
extends Control

signal leave()

@export var name_line_edit: LineEdit
@export var editor_card: EditorCard

@export var health_spin_box: SpinBox
@export var attack_spin_box: SpinBox
@export var cost_spin_box: SpinBox


func _ready() -> void:
	editor_card.set_health(int(health_spin_box.value))
	editor_card.set_attack(int(attack_spin_box.value))
	editor_card.set_cost(int(cost_spin_box.value))
	CardFile.ensure_folder_exists()


func _on_back_button_pressed() -> void:
	leave.emit()


func _on_health_spin_box_value_changed(value: int) -> void:
	editor_card.set_health(value)


func _on_attack_spin_box_value_changed(value: int) -> void:
	editor_card.set_attack(value)


func _on_cost_spin_box_value_changed(value: int) -> void:
	editor_card.set_cost(value)


func _on_save_button_pressed() -> void:
	editor_card.save()


func _on_name_line_edit_text_changed(_new_text: String) -> void:
	editor_card.set_card_name(name_line_edit.text)


func _on_open_folder_button_pressed() -> void:
	# 1. Convert "user://" to a real system path (e.g., C:/Users/Name/AppData...)
	var absolute_path = ProjectSettings.globalize_path(PathConstants.CARD_SAVE_PATH)
	
	# 2. Tell the OS to open that path in the default file explorer
	OS.shell_open(absolute_path)


func _on_load_button_pressed() -> void:
	# Define the filters (Extension, then Description)
	var filters = PackedStringArray(["*.json ; Save Data"])
	
	# Open the native dialog
	DisplayServer.file_dialog_show(
		"Select a Card to Load", # Title of the window
		ProjectSettings.globalize_path(PathConstants.CARD_SAVE_PATH), # Initial directory
		"", # Default filename (leave empty for opening)
		false, # Boolean: Show hidden files?
		DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, # Mode (Open File, Save, etc)
		filters, # The filters we defined above
		_on_card_file_selected # The function to call when they pick something
	)


func _on_card_file_selected(status: bool, selected_paths: PackedStringArray, _selected_filter_index: int):
	if status:
		# status is true if they clicked 'Open', false if they clicked 'Cancel'
		var chosen_path = selected_paths[0]
		print("Load Card selected: ", chosen_path)
		load_card(chosen_path)
	else:
		print("User cancelled the selection.")


func load_card(path: String):
	editor_card.load(path)
	update_values_from_loaded_card()


func update_values_from_loaded_card():
	name_line_edit.text = editor_card.get_card_name()
	health_spin_box.value = editor_card.get_health()
	attack_spin_box.value = editor_card.get_attack()
	cost_spin_box.value = editor_card.get_cost()
