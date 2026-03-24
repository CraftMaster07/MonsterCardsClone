class_name DeckCreator
extends Control

@export var collection_container: CollectionContainer
@export var deck_container: DeckContainer

@export var editor_card_scene: PackedScene
@export var editor_card_container_scene: PackedScene

var cards_in_deck: Dictionary[String, int] = {}

signal leave()


func _ready():
	load_cards()


func _on_back_button_pressed() -> void:
	leave.emit()


func load_cards():
	var card_paths = get_all_json_from_path(PathConstants.CARD_SAVE_PATH)

	for card_path in card_paths:
		var card = load_card(card_path)
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
	card.load(card_path)
	print("Loaded Card: ", card.get_card_name())
	return card


func add_card_to_collection(card: EditorCard) -> void:
	collection_container.add_card(card)


func _on_collection_container_card_selected(card: EditorCard) -> void:
	if cards_in_deck.has(card.get_card_name()):
		cards_in_deck[card.get_card_name()] += 1
		deck_container.increment_card_amount(card.get_card_name())
		return
	
	var card_name = card.get_card_name()
	var new_card = editor_card_scene.instantiate()
	new_card.deserialize(card.serialize())
	var card_container = editor_card_container_scene.instantiate()
	card_container.add_card(new_card)
	deck_container.add_card_container(card_name, card_container)
	cards_in_deck[card_name] = 1


func _on_deck_container_card_decremented(card_name: String) -> void:
	cards_in_deck[card_name] -= 1

	if cards_in_deck[card_name] == 0:
		deck_container.remove_card_container_by_name(card_name)
		cards_in_deck.erase(card_name)
