extends Control

@export var PlayMenuContainer: Control
@export var HostMenu: Control
@export var JoinMenu: Control


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


func _on_host_button_pressed() -> void:
	if JoinMenu.visible:
		JoinMenu.visible = false
	HostMenu.visible = true


func _on_join_button_pressed() -> void:
	if HostMenu.visible:
		HostMenu.visible = false
	JoinMenu.visible = true


func _on_host_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Board/board.tscn")


func _on_join_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Board/board.tscn")
