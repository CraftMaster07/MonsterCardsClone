class_name DeckCreator
extends Control

@export var collection_container: CollectionContainer
@export var deck_container: DeckContainer
@export var deck_name_line_edit: LineEdit

@export var editor_card_scene: PackedScene

var deck_file: DeckFile = DeckFile.new()

signal leave()


func _ready():
	CardFile.ensure_folder_exists()
	DeckFile.ensure_folder_exists()
	load_cards()


func _on_back_button_pressed() -> void:
	leave.emit()


func load_cards():
	var card_paths = get_all_json_from_path(PathConstants.CARD_SAVE_PATH)

	for card_path in card_paths:
		var card: EditorCard = load_card(card_path)

		if card:
			add_card_to_collection(card)


static func get_all_json_from_path(folder_path: String) -> Array:
	var all_paths = []
	var dir = DirAccess.open(folder_path)

	if dir:
		# Get all filenames in the directory
		var files = dir.get_files()

		for file_name in files:
			# Check if the file has a .json extension
			if file_name.get_extension().to_lower() == "json":
				var full_path = folder_path.path_join(file_name)
				all_paths.append(full_path)
	else:
		print("An error occurred when trying to access the path: ", folder_path)

	return all_paths


func load_card(card_path: String) -> EditorCard:
	var card = editor_card_scene.instantiate()

	if not card.load(card_path):
		print("Failed to load card: ", card_path)
		return null

	print("Loaded Card: ", card.get_card_name())
	return card


func add_card_to_collection(card: EditorCard) -> void:
	collection_container.add_card(card)


func _on_collection_container_card_selected(card: EditorCard) -> void:
	var card_name = card.get_file_name()
	if card_name in deck_file.cards:
		deck_file.cards[card_name] += 1
		deck_container.increment_card_amount(card_name)
		return

	var new_card = editor_card_scene.instantiate()
	new_card.deserialize(card.serialize())
	deck_container.add_card_container(card_name, new_card)
	deck_file.cards[card_name] = 1


func _on_deck_container_card_decremented(card_name: String) -> void:
	deck_file.cards[card_name] -= 1

	if deck_file.cards[card_name] == 0:
		deck_container.remove_card_container(card_name)
		deck_file.cards.erase(card_name)
	else:
		deck_container.decrement_card_amount(card_name)


func _on_save_button_pressed() -> void:
	save_deck()


func _on_deck_line_edit_text_changed(new_text: String) -> void:
	deck_file.name = new_text


func update_deck_line_edit() -> void:
	deck_name_line_edit.text = deck_file.name


func save_deck() -> void:
	deck_file.save()


func load_deck(file_path: String) -> void:
	deck_file.load(file_path)
	update_deck_line_edit()
	update_deck_container()


func update_deck_container():
	for file_name in deck_file.cards:
		if file_name in deck_container.card_containers:
			deck_container.update_card_amount(file_name, deck_file.cards[file_name])
		else:
			var card = load_card(PathConstants.CARD_SAVE_PATH + file_name + ".json")
			deck_container.add_card_container(file_name, card)
			deck_container.update_card_amount(file_name, deck_file.cards[file_name])

	for card_name in deck_container.card_containers:
		if card_name not in deck_file.cards:
			deck_container.remove_card_container(card_name)

func _on_load_button_pressed() -> void:
	# Define the filters (Extension, then Description)
	var filters = PackedStringArray(["*.json ; Save Data"])

	# Open the native dialog
	DisplayServer.file_dialog_show(
		"Select a Deck to Load", # Title of the window
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
		load_deck(chosen_path)
	else:
		print("User cancelled the selection.")
