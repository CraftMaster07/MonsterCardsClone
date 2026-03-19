extends Control

signal leave()


func _on_back_button_pressed() -> void:
	leave.emit()
