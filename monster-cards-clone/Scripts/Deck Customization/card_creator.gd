extends Control

signal leave()

var card_file = CardFile.new()
@export var name_line_edit: LineEdit


func _on_back_button_pressed() -> void:
	leave.emit()


func _on_health_spin_box_value_changed(value: float) -> void:
	card_file.health = value


func _on_attack_spin_box_value_changed(value: float) -> void:
	card_file.attack = value

func _on_cost_spin_box_value_changed(value: float) -> void:
	card_file.cost = value


func _on_save_button_pressed() -> void:
	card_file.save()


func _on_name_line_edit_text_changed(_new_text: String) -> void:
	card_file.card_name = name_line_edit.text
