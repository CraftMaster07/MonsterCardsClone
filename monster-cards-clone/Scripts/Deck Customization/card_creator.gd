class_name CardCreator
extends Control

signal leave()

@export var name_line_edit: LineEdit
@export var editor_card: EditorCard

@export var health_spin_box: SpinBox
@export var attack_spin_box: SpinBox
@export var cost_label: Label

@export var ability_toggle_button: Button

@export var effect_label: Label
@export var target_label: Label
@export var trigger_label: Label
@export var effect_dropdown: OptionButton
@export var target_dropdown: OptionButton
@export var trigger_dropdown: OptionButton

var _current_effects: Array = []
var _current_targets: Array = []
var _current_triggers: Array = []


func _ready() -> void:
	editor_card.set_health(int(health_spin_box.value))
	editor_card.set_attack(int(attack_spin_box.value))
	editor_card.set_cost(int(cost_label.text))
	CardFile.ensure_folder_exists()
	fill_options()

	_on_ability_toggle_button_toggled(false)


static func calculate_cost(health, attack) -> int:
	var attack_component = pow(attack, 1.2) * 0.7
	var health_component = pow(health, 0.9) * 0.5
	
	var total = attack_component + health_component
	return int(round(total))


func _on_back_button_pressed() -> void:
	leave.emit()


func _on_health_spin_box_value_changed(value: int) -> void:
	editor_card.set_health(value)
	update_cost()


func _on_attack_spin_box_value_changed(value: int) -> void:
	editor_card.set_attack(value)
	update_cost()


func _on_save_button_pressed() -> void:
	editor_card.save()


func _on_name_line_edit_text_changed(new_text: String) -> void:
	editor_card.set_card_name(new_text)


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
	update_cost()

	ability_toggle_button.button_pressed = editor_card.has_ability()
	if editor_card.has_ability():
		update_effect_from_loaded_card()
		update_trigger_from_loaded_card()


func update_cost():
	var new_cost: int = calculate_cost(health_spin_box.value, attack_spin_box.value)
	cost_label.text = " " + str(new_cost)
	editor_card.set_cost(new_cost)


func fill_options():
	fill_effect_options()
	fill_trigger_options()
	_on_effect_option_button_item_selected(effect_dropdown.get_selected_id())


func fill_effect_options():
	_current_effects = []

	for effect in EffectFactory.get_effects():
		effect_dropdown.add_item(effect.get_display_name())
		_current_effects.append(effect)


func fill_trigger_options(effect: Effect = null):
	_current_triggers = []

	for trigger in TriggerFactory.get_triggers():
		if effect and effect.check_trigger_compatibility(trigger.get_id()):
			trigger_dropdown.add_item(trigger.get_display_name())
			_current_triggers.append(trigger)


func format_text(text: String) -> String:
	var word_list = text.split("_")

	for i in len(word_list):
		var word = word_list[i]
		word_list[i] = word[0].to_upper() + word.substr(1).to_lower()
	
	return " ".join(word_list)


func _on_ability_toggle_button_toggled(toggled_on: bool) -> void:
	effect_label.visible = toggled_on
	effect_dropdown.visible = toggled_on

	target_label.visible = toggled_on
	target_dropdown.visible = toggled_on
	
	trigger_label.visible = toggled_on
	trigger_dropdown.visible = toggled_on

	if toggled_on:
		_on_effect_option_button_item_selected(0)
	else:
		editor_card.remove_ability()


func _on_effect_option_button_item_selected(index: int) -> void:
	var effect = _current_effects[index]
	update_targets_from_effect(effect)
	_on_target_option_button_item_selected(target_dropdown.get_selected_id())
	update_triggers_from_effect(effect)
	update_editor_card_ability()


func update_targets_from_effect(effect: Effect):
	var valid_targets = effect.target_whitelist.keys()
	target_dropdown.clear()
	_current_targets = []
	
	for target in valid_targets:
		target_dropdown.add_item(format_text(Effect.get_target_name(target)))
		_current_targets.append(target)


func update_triggers_from_effect(effect: Effect):
	trigger_dropdown.clear()
	fill_trigger_options(effect)


func update_editor_card_ability():
	editor_card.set_effect(_current_effects[effect_dropdown.get_selected_id()])
	editor_card.set_trigger(_current_triggers[trigger_dropdown.get_selected_id()])


func _on_target_option_button_item_selected(index: int) -> void:
	_current_effects[effect_dropdown.get_selected_id()].target = _current_targets[index]


func _on_trigger_option_button_item_selected(_index: int) -> void:
	update_editor_card_ability()


func update_effect_from_loaded_card():
	var effect = editor_card.get_effect()
	effect_dropdown.select(get_index_from_effect(effect))

	update_targets_from_effect(effect)
	target_dropdown.select(get_index_from_target(effect.target))
	#_on_target_option_button_item_selected(get_index_from_target(effect.target))

func update_trigger_from_loaded_card():
	trigger_dropdown.select(get_index_from_trigger(editor_card.get_trigger()))


# This is an expensive function, try to avoid calling it too often
func get_index_from_effect(effect: Effect) -> int:
	return get_index_from_value(effect, _current_effects, true)


func get_index_from_target(target: int) -> int:
	return get_index_from_value(target, _current_targets, false)


func get_index_from_trigger(trigger: Trigger) -> int:
	return get_index_from_value(trigger, _current_triggers, true)


func get_index_from_value(value: Variant, array: Array, should_compare_ids: bool = false) -> int:
	for i in len(array):
		if should_compare_ids:
			if array[i].get_id() == value.get_id():
				return i
		else:
			if array[i] == value:
				return i

	return -1


func _on_serialize_button_pressed() -> void:
	#continue testing with this
	#should check that saving and loading works
	var serialized = editor_card.serialize()
	print(serialized)
