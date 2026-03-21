class_name PlayerArea
extends Control

@onready var field: Field = $Field
@onready var deck: Deck = $Deck
@onready var hand: Hand = $Hand


func get_field() -> Field:
	return field


func get_deck() -> Deck:
	return deck


func get_hand() -> Hand:
	return hand
