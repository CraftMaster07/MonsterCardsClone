class_name CardData
extends Node

@export var card_name: String
@export var sprite_hash: String

# maybe implement starting stats differently
const STARTING_HEALTH = 2
const STARTING_ATTACK = 1
const STARTING_COST = 2

var uuid: String
var owner_id: int

var max_health: int
var health: int
var attack: int
var cost: int

var is_ghost: bool = false

var ability: Ability

const TRIGGER_ID = Trigger.TriggerID
var triggers_to_signals: Dictionary = {
	TRIGGER_ID.WHEN_HURT: ouch,
}

signal updated_stats()
signal updated_sprite(new_sprite_hash: String)
signal ouch()

static func create_from_card_file(card_file: CardFile, new_owner_id: int = -1) -> CardData:
	var card_data = CardData.new()
	card_data.card_name = card_file.card_name
	card_data.health = card_file.health
	card_data.max_health = card_file.health
	card_data.attack = card_file.attack
	card_data.cost = card_file.cost
	card_data.ability = card_file.ability
	card_data.owner_id = new_owner_id

	var new_sprite_hash = CardSpriteManager.add_sprite(card_file.get_serialized_card_image())
	card_data.update_sprite_hash(new_sprite_hash)

	return card_data


func _init(serialized_data: Dictionary = {}, new_owner_id: int = -1):
	if serialized_data:
		uuid = serialized_data["uuid"]
		deserialize(serialized_data)
	else:
		uuid = UUID.v4()
		health = STARTING_HEALTH
		max_health = STARTING_HEALTH
		attack = STARTING_ATTACK
		cost = STARTING_COST

	if new_owner_id != -1:
		owner_id = new_owner_id

	updated_stats.emit()


func serialize() -> Dictionary:
	var data: Dictionary = {
		"name": card_name,
		"health": health,
		"max_health": max_health,
		"attack": attack,
		"cost": cost,
		"sprite_hash": sprite_hash,
		"owner_id": owner_id,
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
	owner_id = data["owner_id"]

	if data.has("ability"):
		ensure_ability_exists()
		ability.deserialize(data["ability"])
	else:
		ability = null
	
	if data.has("sprite_hash"):
		update_sprite_hash(data["sprite_hash"])

	check_death()
	updated_stats.emit()


func recalculate_cost():
	if not has_ability():
		cost = CardEditor.calculate_cost(health, attack)
	else:
		cost = CardEditor.calculate_cost(health, attack, ability.get_trigger_multiplier(), ability.get_effect_multiplier(), ability.get_target_multiplier())


func take_damage(amount: int) -> void:
	if health <= 0: return
	health -= amount
	card_trigger(TRIGGER_ID.WHEN_HURT)
	check_death()
	updated_stats.emit()


func check_death():
	if health <= 0:
		print_rich("[color=red]Card destroyed![/color]")
		die()


func die():
	is_ghost = true


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
	if not ability: return Trigger.TriggerID.INVALID
	return ability.get_trigger().get_id()


func run_ability():
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
	return ability != null and ability.is_valid()


func ensure_ability_exists():
	if not has_ability():
		ability = Ability.new(null, null)


func is_dead() -> bool:
	return is_ghost


func set_owner_id(new_owner_id: int):
	owner_id = new_owner_id


func get_owner_id() -> int:
	return owner_id


func card_trigger(trigger_id):
	print("card ", uuid, ": triggering card trigger: ", trigger_id)
	triggers_to_signals[trigger_id].emit()


func update_sprite_hash(new_hash: String):
	if sprite_hash != new_hash:
		sprite_hash = new_hash
		updated_sprite.emit(new_hash)


func get_sprite_hash() -> String:
	return sprite_hash
