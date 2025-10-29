class_name Player
extends Node

var STARTING_HEALTH = 20
@export var health : int = STARTING_HEALTH

@onready var label: Label = $HealthLabel


func _ready():
	_update_health()


func hit() -> void:
	print("ouch!")
	_decrease_health(1)


func _decrease_health(amount: int) -> void:
	health -= amount
	_update_health()


func _update_health() -> void:
	label.text = str(health) + "\\" + str(STARTING_HEALTH)


func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		hit()
