extends RefCounted
class_name CardFile


const TRIGGER = Ability.TRIGGER

var card_name: String = ""
var file_name: String = ""
var health: int = 0
var attack: int = 0
var cost: int = 0

var ability: Ability = Ability.new(TRIGGER.INVALID, null)


func save():
	ensure_folder_exists()

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
		"cost": cost,
		"ability": ability.serialize()
	}


func load(file_path: String):
	var file := FileAccess.open(file_path, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	deserialize(data)
	file.close()


func deserialize(data: Dictionary):
	set_name(data["card_name"])
	health = data["health"]
	attack = data["attack"]
	cost = data["cost"]
	ability.deserialize(data["ability"])


func set_name(name: String) -> void:
	card_name = name
	file_name = name.replace(" ", "_")


static func ensure_folder_exists():
	if not DirAccess.dir_exists_absolute(PathConstants.CARD_SAVE_PATH):
		DirAccess.make_dir_absolute(PathConstants.CARD_SAVE_PATH)


func set_trigger(trigger: Ability.TRIGGER):
	ability.trigger = trigger


func set_effect(effect: Effect):
	ability.effect = effect
