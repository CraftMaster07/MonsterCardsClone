extends Control

signal host_game(name: String)
signal join_game(name: String, ip: String)

@export var PlayMenuContainer: Control
@export var SettingsMenuContainer: Control
@export var HostMenu: Control
@export var JoinMenu: Control
@export var NameLineEdit: LineEdit
@export var IPLineEdit: LineEdit

var menu_containers: Array[Control] = []

func _ready() -> void:
	menu_containers = [PlayMenuContainer, SettingsMenuContainer]


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
	toggle_menu(PlayMenuContainer)


func _on_settings_button_pressed() -> void:
	toggle_menu(SettingsMenuContainer)


func _on_quit_button_pressed() -> void:
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


func _on_name_line_edit_text_changed(new_text: String) -> void:
	check_gaster(new_text)


func check_gaster(player_name: String) -> void:
	if player_name.to_lower().find("gaster") != -1:
		get_tree().quit()