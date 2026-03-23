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
