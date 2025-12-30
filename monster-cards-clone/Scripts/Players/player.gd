class_name Player
extends Node

const STARTING_HEALTH: int = 20
var health: int
var deck: Array
var hand: PackedScene
var player_name: String
var player_id: int

@onready var label: Label = $HealthLabel


func _init(new_player_id: int, new_player_name: String):
	player_id = new_player_id
	player_name = new_player_name
	health = STARTING_HEALTH


func _ready():
	update_health()


func hit() -> void:
	print("ouch!")
	decrease_health(1)


func decrease_health(amount: int) -> void:
	health -= amount
	update_health()


func update_health() -> void:
	label.text = str(health) + "\\" + str(STARTING_HEALTH)


func _on_damage_button_pressed() -> void:
	hit()
