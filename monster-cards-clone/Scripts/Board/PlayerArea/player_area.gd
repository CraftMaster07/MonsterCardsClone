class_name PlayerArea
extends Control

@onready var field: Field = $Field
@onready var deck: Deck = $Deck
@onready var hand: Hand = $Hand
@onready var health_icon: StatIcon = $HealthIcon
@onready var mana_icon: StatIcon = $ManaIcon


func get_field() -> Field:
	return field


func get_deck() -> Deck:
	return deck


func get_hand() -> Hand:
	return hand
	

func get_health_icon() -> StatIcon:
	return health_icon


func get_mana_icon() -> StatIcon:
	return mana_icon


func get_attack_button() -> Button:
	# should split to enemy_player_area
	return $AttackButton
