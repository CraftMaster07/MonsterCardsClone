class_name CardCreator
extends Control

signal leave()

var card_file = CardFile.new()
@export var name_line_edit: LineEdit
@export var card_front: CardFront

@export var health_spin_box: SpinBox
@export var attack_spin_box: SpinBox
@export var cost_spin_box: SpinBox


func _ready() -> void:
	set_display_health(int(health_spin_box.value))
	set_display_attack(int(attack_spin_box.value))
	set_display_cost(int(cost_spin_box.value))
	CardFile.ensure_folder_exists()


func _on_back_button_pressed() -> void:
	leave.emit()


func _on_health_spin_box_value_changed(value: int) -> void:
	card_file.health = value
	set_display_health(value)


func _on_attack_spin_box_value_changed(value: int) -> void:
	card_file.attack = value
	set_display_attack(value)


func _on_cost_spin_box_value_changed(value: int) -> void:
	card_file.cost = value
	set_display_cost(value)


func _on_save_button_pressed() -> void:
	card_file.save()


func _on_name_line_edit_text_changed(_new_text: String) -> void:
	card_file.card_name = name_line_edit.text


func set_display_health(health: int) -> void:
	card_front.set_initial_health(health)


func set_display_attack(attack: int) -> void:
	card_front.set_initial_attack(attack)


func set_display_cost(cost: int) -> void:
	card_front.set_initial_cost(cost)


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
	card_file.load(path)
	update_values_from_loaded_card()


func update_values_from_loaded_card():
	name_line_edit.text = card_file.card_name
	health_spin_box.value = card_file.health
	attack_spin_box.value = card_file.attack
	cost_spin_box.value = card_file.cost
	update_display()


func update_display():
	set_display_health(card_file.health)
	set_display_attack(card_file.attack)
	set_display_cost(card_file.cost)
