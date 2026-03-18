class_name CardData
extends Resource

@export var card_name: String
@export var image_id: int
var old_image_id: int

# maybe implement starting stats differently
const STARTING_HEALTH = 2
const STARTING_ATTACK = 1
const STARTING_COST = 2

var uuid: String

var health: int
var attack: int
var cost: int

var is_ghost: bool = false


func _init(serialized_data: Dictionary = {}):
	if serialized_data:
		uuid = serialized_data["uuid"]
		deserialize(serialized_data)
	else:
		uuid = UUID.v4()
		health = STARTING_HEALTH
		attack = STARTING_ATTACK
		cost = STARTING_COST


func serialize() -> Dictionary:
	return {
		"uuid": uuid,
		"data": {
			"name": card_name,
			"health": health,
			"attack": attack,
			"cost": cost,
			"image_id": image_id,
		}
	}


func deserialize(serialized: Dictionary):
	if serialized["uuid"] != uuid:
		push_error("uuid mismatch: " + serialized["uuid"] + " != " + uuid)

	var data: Dictionary = serialized["data"]
	card_name = data["name"]
	health = data["health"]
	attack = data["attack"]
	cost = data["cost"]
	image_id = data["image_id"]
	check_death()


func take_damage(amount : int) -> void:
	health -= amount
	check_death()


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
