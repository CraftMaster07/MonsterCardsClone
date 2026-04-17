class_name CardData
extends Node

@export var card_name: String
@export var image_id: int
var old_image_id: int

# maybe implement starting stats differently
const STARTING_HEALTH = 2
const STARTING_ATTACK = 1
const STARTING_COST = 2

var uuid: String

var max_health: int
var health: int
var attack: int
var cost: int

var is_ghost: bool = false

var ability: Ability

signal updated_stats()

static func create_from_card_file(card_file: CardFile):
	var card_data = CardData.new()
	card_data.card_name = card_file.card_name
	card_data.health = card_file.health
	card_data.max_health = card_file.health
	card_data.attack = card_file.attack
	card_data.cost = card_file.cost
	return card_data


func _init(serialized_data: Dictionary = {}):
	if serialized_data:
		uuid = serialized_data["uuid"]
		deserialize(serialized_data)
	else:
		uuid = UUID.v4()
		health = STARTING_HEALTH
		max_health = STARTING_HEALTH
		attack = STARTING_ATTACK
		cost = STARTING_COST
	updated_stats.emit()


func serialize() -> Dictionary:
	var data: Dictionary = {
		"name": card_name,
		"health": health,
		"max_health": max_health,
		"attack": attack,
		"cost": cost,
		"image_id": image_id,
	}

	if ability:
		data["ability"] = ability.serialize()

	return {
		"uuid": uuid,
		"data": data
	}


func deserialize(serialized: Dictionary):
	if serialized["uuid"] != uuid:
		push_error("uuid mismatch: " + serialized["uuid"] + " != " + uuid)

	var data: Dictionary = serialized["data"]
	card_name = data["name"]
	health = data["health"]
	max_health = data["max_health"]
	attack = data["attack"]
	cost = data["cost"]
	image_id = data["image_id"]

	if data.has("ability"):
		ability.deserialize(data["ability"])
	else:
		ability = null

	check_death()
	updated_stats.emit()


func recalculate_cost():
	cost = CardCreator.calculate_cost(health, attack)


func take_damage(amount: int) -> void:
	health -= amount
	check_death()
	updated_stats.emit()


func check_death():
	if health <= 0:
		print_rich("[color=red]Card destroyed![/color]")
		die()


func die():
	is_ghost = true


func query_updated_image_id():
	if image_id != old_image_id:
		old_image_id = image_id
		return image_id
	return null


func hit(target):
	if target.has_method("take_damage"):
		target.take_damage(attack)
	else:
		push_error("target does not have take_damage method")


func reset():
	health = STARTING_HEALTH
	attack = STARTING_ATTACK
	cost = STARTING_COST


func get_trigger() -> Trigger:
	return ability.get_trigger()


func get_trigger_id() -> Trigger.TriggerID:
	return ability.get_trigger().get_id()


func run_ability():
	print("Ability ran")
	ability.run()


func heal(amount: int):
	health = min(health + amount, max_health)
	updated_stats.emit()


func buff_attack(amount: int):
	attack += amount
	updated_stats.emit()


func get_ability_signal() -> Signal:
	return ability.activated


func has_ability() -> bool:
	return ability != null
