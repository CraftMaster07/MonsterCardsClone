extends Control

@export var PlayMenuContainer: Control

func _on_idk_button_pressed() -> void:
	print("why would you press this?")


func _on_deck_button_pressed() -> void:
	print("deck button pressed")
	

func _on_play_button_pressed() -> void:
	print("play button pressed")
	PlayMenuContainer.visible = !PlayMenuContainer.visible


func _on_settings_button_pressed() -> void:
	print("settings button pressed")


func _on_quit_button_pressed() -> void:
	print_rich("quit button pressed")
	get_tree().quit()
