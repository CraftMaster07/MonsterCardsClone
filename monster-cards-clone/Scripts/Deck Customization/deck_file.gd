extends RefCounted
class_name DeckFile

var name: String
var cards: Dictionary


func serialize() -> Dictionary:
	return {
		"name": name,
		"cards": cards
	}


func deserialize(data: Dictionary):
	name = data["name"]
	cards = data["cards"]


func save():
	ensure_folder_exists()

	var file_name := name.replace(" ", "_")
	var file := FileAccess.open(PathConstants.DECK_SAVE_PATH + file_name + ".json", FileAccess.WRITE)
	var stringified_data := JSON.stringify(serialize())
	file.store_string(stringified_data)
	file.close()


func load(file_path: String):
	var file := FileAccess.open(file_path, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	deserialize(data)

static func ensure_folder_exists():
	if not DirAccess.dir_exists_absolute(PathConstants.DECK_SAVE_PATH):
		DirAccess.make_dir_absolute(PathConstants.DECK_SAVE_PATH)
