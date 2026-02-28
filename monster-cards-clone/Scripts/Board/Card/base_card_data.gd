class_name BaseCardData
extends Resource

@export var display_name : String
@export var description : String
@export var image : Texture2D

@export var cost : int = 1:
	set(value):
		cost = clamp(value, -999, 999)
@export var damage : int = 1:
	set(value):
		damage = clamp(value, -999, 999)
@export var health : int = 1:
	set(value):
		health = clamp(value, 0, 999)

var current_cost : int
var current_damage : int
var current_health : int


func take_damage(amount : int) -> void:
	current_health -= amount
	if current_health <= 0:
		pass
		#DIE
