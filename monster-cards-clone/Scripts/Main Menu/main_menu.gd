extends Control

@export var PlayMenuContainer: Control
@export var SettingsMenuContainer: Control
@export var HostMenu: Control
@export var JoinMenu: Control

var menu_containers: Array[Control] = []

func _ready() -> void:
	menu_containers = [PlayMenuContainer, SettingsMenuContainer]


func _close_all_menus() -> void:
	for menu in menu_containers:
		menu.visible = false


func _toggle_menu(menu: Control) -> void:
	if menu.visible:
		menu.visible = false
	else:
		# Close all other menus, then open this one
		_close_all_menus()
		menu.visible = true


func _on_idk_button_pressed() -> void:
	print("why would you press this?")


func _on_deck_button_pressed() -> void:
	pass


func _on_play_button_pressed() -> void:
	_toggle_menu(PlayMenuContainer)


func _on_settings_button_pressed() -> void:
	_toggle_menu(SettingsMenuContainer)


func _on_quit_button_pressed() -> void:
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
