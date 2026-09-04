extends RefCounted
class_name CardFile

var card_name: String = ""
var file_name: String = ""
var health: int = 0
var attack: int = 0
var cost: int = 0
var serialized_sprite: Dictionary

var ability: Ability


func save():
	ensure_folder_exists()

	var file := FileAccess.open(PathConstants.CARD_SAVE_PATH.path_join(file_name + ".json"), FileAccess.WRITE)
	var data := serialize()
	var stringified_data := JSON.stringify(data)
	file.store_string(stringified_data)
	file.close()


func serialize() -> Dictionary:
	var data: Dictionary = {
		"card_name": card_name,
		"health": health,
		"attack": attack,
		"cost": cost,
		"serialized_sprite": serialized_sprite if serialized_sprite else {}
	}

	if has_ability():
		data["ability"] = ability.serialize()

	return data


func lightweight_serialize() -> Dictionary:
	var data: Dictionary = serialize()
	data.erase("serialized_sprite")
	return data


func load(file_path: String) -> bool:
	var file := FileAccess.open(file_path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())

	if not data:
		return false

	deserialize(data)
	file.close()

	return true


func deserialize(data: Dictionary):
	set_name(data["card_name"])
	health = data["health"]
	attack = data["attack"]
	cost = data["cost"]

	if data.has("serialized_sprite") and data["serialized_sprite"] != {}:
		serialized_sprite = data["serialized_sprite"]

	if data.has("ability") and data["ability"] != {}:
		ensure_ability_exists()
		ability.deserialize(data["ability"])
	else:
		remove_ability()


func set_name(name: String) -> void:
	card_name = name
	file_name = name.replace(" ", "_")


static func ensure_folder_exists():
	if not DirAccess.dir_exists_absolute(PathConstants.CARD_SAVE_PATH):
		var err = DirAccess.make_dir_absolute(PathConstants.CARD_SAVE_PATH)

		if err != OK:
			push_error("Failed to create baked sprites directory. Error code: ", err)


func set_trigger(trigger: Trigger):
	ensure_ability_exists()
	ability.trigger = trigger


func set_effect(effect: Effect):
	ensure_ability_exists()
	ability.effect = effect


func get_effect() -> Effect:
	ensure_ability_exists()
	return ability.effect


func get_trigger() -> Trigger:
	ensure_ability_exists()
	return ability.trigger


func has_ability() -> bool:
	return ability != null and ability.is_valid()


func has_any_ability() -> bool:
	return ability != null


func remove_ability():
	ability = null


func ensure_ability_exists():
	if not has_any_ability():
		ability = Ability.new(null, null)


func get_trigger_multiplier() -> float:
	ensure_ability_exists()
	return ability.get_trigger_multiplier()


func get_effect_multiplier() -> float:
	ensure_ability_exists()
	return ability.get_effect_multiplier()


func get_target_multiplier() -> float:
	ensure_ability_exists()
	return ability.get_target_multiplier()


func set_serialized_sprite(new_serialized_sprite: Dictionary):
	serialized_sprite = new_serialized_sprite


func get_serialized_sprite() -> Dictionary:
	return serialized_sprite
