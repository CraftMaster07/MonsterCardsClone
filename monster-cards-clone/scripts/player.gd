extends Node
class_name Player

var STARTING_HEALTH = 20
@export var health : int = STARTING_HEALTH

@onready var label: Label = $HealthLabel

func __init__():
	label.text = str(health) + "\\" + str(STARTING_HEALTH)

func hit() -> void:
	print("ouch!")
	_decrease_health(1)

func _decrease_health(_amount: int) -> void:
	health -= _amount
	label.text = str(health) + "\\" + str(STARTING_HEALTH)


func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		hit()
