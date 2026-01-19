class_name Player
extends Node

const STARTING_HEALTH: int = 20
var health: int
var deck: Array
var field: Field
var hand: PackedScene
var player_name: String
var player_id: int

@onready var label: Label = $HealthLabel


func init(new_player_id: int, new_player_name: String, health: int = STARTING_HEALTH):
	player_id = new_player_id
	player_name = new_player_name
	health = health


func _ready():
	update_health()


func hit() -> void:
	print("ouch!")
	decrease_health(1)


func decrease_health(amount: int) -> void:
	health -= amount
	update_health()


func update_health() -> void:
	label.text = player_name + ": " + str(health) + "\\" + str(STARTING_HEALTH)


func _on_damage_button_pressed() -> void:
	hit()


func get_field():
	return field


func set_field(new_field: Field):
	field = new_field


func serialize():
	return {
		"player_id": player_id,
		"player_name": player_name,
		"health": health,
		"field": field.serialize(),
	}


func deserialise(serialized_player: Dictionary):
	player_id = serialized_player['player_id']
	player_name = serialized_player['player_name']
	health = serialized_player['health']
	update_health()
	field.deserialise(serialized_player['field'])
	
