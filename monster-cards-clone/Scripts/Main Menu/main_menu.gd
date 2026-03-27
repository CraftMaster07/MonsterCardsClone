extends Control

signal host_game(name: String, deck: DeckFile)
signal join_game(name: String, ip: String, deck: DeckFile)
signal goto_card_creator()
signal goto_deck_creator()

@export var play_menu_container: Control
@export var settings_menu_container: Control
@export var deck_menu_container: Control
@export var host_menu: Control
@export var join_menu: Control
@export var name_line_edit: LineEdit
@export var ip_line_edit: LineEdit
@export var join_status_label: Label
@export var select_deck_label: Label

var menu_containers: Array[Control] = []
var deck: DeckFile


func _ready() -> void:
	menu_containers = [play_menu_container, settings_menu_container, deck_menu_container]


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
	toggle_menu(deck_menu_container)


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
	if not deck:
		print("No deck selected")
		return
	print("Hosting game")
	host_game.emit(name_line_edit.text, deck)


func _on_join_start_button_pressed() -> void:
	if not deck:
		print("No deck selected")
		return
	print("Joining game")
	join_game.emit(name_line_edit.text, ip_line_edit.text, deck)
	join_status_label.visible = true
	join_status_label.text = "Connecting..."


func _on_name_line_edit_text_changed(new_text: String) -> void:
	check_gaster(new_text)


func check_gaster(player_name: String) -> void:
	if player_name.to_lower().find("gaster") != -1:
		get_tree().quit()


func _on_card_creator_button_pressed() -> void:
	goto_card_creator.emit()


func _on_deck_creator_button_pressed() -> void:
	goto_deck_creator.emit()


func _on_select_deck_button_pressed() -> void:
	# Define the filters (Extension, then Description)
	var filters = PackedStringArray(["*.json ; Save Data"])

	# Open the native dialog
	DisplayServer.file_dialog_show(
		"Select a Deck", # Title of the window
		ProjectSettings.globalize_path(PathConstants.DECK_SAVE_PATH), # Initial directory
		"", # Default filename (leave empty for opening)
		false, # Boolean: Show hidden files?
		DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, # Mode (Open File, Save, etc)
		filters, # The filters we defined above
		_on_deck_file_selected # The function to call when they pick something
	)


func _on_deck_file_selected(status: bool, selected_paths: PackedStringArray, _selected_filter_index: int):
	if status:
		# status is true if they clicked 'Open', false if they clicked 'Cancel'
		var chosen_path = selected_paths[0]
		print("Load Deck selected: ", chosen_path)
		select_deck(chosen_path)
	else:
		print("User cancelled the selection.")


func select_deck(file_path) -> void:
	deck = DeckFile.new()
	deck.load(file_path)
	select_deck_label.text = "Selected deck: " + deck.name