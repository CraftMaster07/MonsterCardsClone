extends Control

signal host_game(name: String)
signal join_game(name: String, ip: String)

@export var play_menu_container: Control
@export var settings_menu_container: Control
@export var host_menu: Control
@export var join_menu: Control
@export var name_line_edit: LineEdit
@export var ip_line_edit: LineEdit
@export var join_status_label: Label

var menu_containers: Array[Control] = []


func _ready() -> void:
	menu_containers = [play_menu_container, settings_menu_container]


func reinitialize() -> void:
	join_status_label.text = ""
	join_status_label.visible = false


func close_all_menus() -> void:
	for menu in menu_containers:
		menu.visible = false


func toggle_menu(menu: Control) -> void:
	if menu.visible:
		menu.visible = false
	else:
		# Close all other menus, then open this one
		close_all_menus()
		menu.visible = true


func _on_idk_button_pressed() -> void:
	print("why would you press this?")


func _on_deck_button_pressed() -> void:
	pass


func _on_play_button_pressed() -> void:
	toggle_menu(play_menu_container)


func _on_settings_button_pressed() -> void:
	toggle_menu(settings_menu_container)


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_host_button_pressed() -> void:
	join_menu.visible = false
	host_menu.visible = true


func _on_join_button_pressed() -> void:
	host_menu.visible = false
	join_menu.visible = true


func _on_host_start_button_pressed() -> void:
	host_game.emit(name_line_edit.text)


func _on_join_start_button_pressed() -> void:
	join_game.emit(name_line_edit.text, ip_line_edit.text)
	join_status_label.visible = true
	join_status_label.text = "Connecting..."


func _on_name_line_edit_text_changed(new_text: String) -> void:
	check_gaster(new_text)


func check_gaster(player_name: String) -> void:
	if player_name.to_lower().find("gaster") != -1:
		get_tree().quit()
