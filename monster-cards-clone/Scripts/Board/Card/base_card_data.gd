class_name BaseCardData
extends Resource

static var base_card_data_resource: Resource = preload("res://Scripts/Board/Card/base_card_data.gd")

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

var current_cost : int
var current_damage : int
var current_health : int

func init():
	health = STARTING_HEALTH
	attack = STARTING_ATTACK
	cost = STARTING_COST
	print("base_card_data loaded")


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


func take_damage(amount : int) -> void:
	current_health -= amount
	if current_health <= 0:
		print_rich("[color=red]Card destroyed![/color]")


func query_updated_image_id():
	if image_id != old_image_id:
		old_image_id = image_id
		return image_id
	return null


static func new_with_init():
	var new_card_data = base_card_data_resource.new()
	new_card_data.init()
	return new_card_data
