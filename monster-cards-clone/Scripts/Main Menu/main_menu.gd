extends Control

signal host_game(name: String)
signal join_game(name: String, ip: String)

@export var PlayMenuContainer: Control
@export var HostMenu: Control
@export var JoinMenu: Control
@export var NameLineEdit: LineEdit
@export var IPLineEdit: LineEdit

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
	JoinMenu.visible = false
	HostMenu.visible = true


func _on_join_button_pressed() -> void:
	HostMenu.visible = false
	JoinMenu.visible = true


func _on_host_start_button_pressed() -> void:
	host_game.emit(NameLineEdit.text)


func _on_join_start_button_pressed() -> void:
	join_game.emit(NameLineEdit.text, IPLineEdit.text)
