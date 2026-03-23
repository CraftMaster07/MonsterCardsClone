extends RefCounted
class_name CardFile


var card_name: String = ""
var health: int = 0
var attack: int = 0
var cost: int = 0


func save():
	if not DirAccess.dir_exists_absolute(PathConstants.CARD_SAVE_PATH):
		DirAccess.make_dir_absolute(PathConstants.CARD_SAVE_PATH)
	
	var file_name := card_name.replace(" ", "_")
	var file := FileAccess.open(PathConstants.CARD_SAVE_PATH + file_name + ".json", FileAccess.WRITE)
	var data := serialize()
	var stringified_data := JSON.stringify(data)
	file.store_string(stringified_data)
	file.close()


func serialize() -> Dictionary:
	return {
		"card_name": card_name,
		"health": health,
		"attack": attack,
		"cost": cost
	}


func load(file_path: String):
	var file := FileAccess.open(file_path, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	deserialize(data)
	file.close()


func deserialize(data: Dictionary):
	card_name = data["card_name"]
	health = data["health"]
	attack = data["attack"]
	cost = data["cost"]
