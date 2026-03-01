class_name CardData
extends Resource

@export var card_name: String
@export var image_id: int
var old_image_id: int

# maybe implement starting stats differently
const STARTING_HEALTH = 2
const STARTING_ATTACK = 1
const STARTING_COST = 1

var health: int
var attack: int
var cost: int

var is_ghost: bool = false

func _init():
	health = STARTING_HEALTH
	attack = STARTING_ATTACK
	cost = STARTING_COST


func serialize() -> Dictionary:
	return {
		"name": card_name,
		"health": health,
		"attack": attack,
		"cost": cost,
		"image_id": image_id,
	}


func deserialize(data):
	card_name = data["name"]
	health = data["health"]
	attack = data["attack"]
	cost = data["cost"]
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
