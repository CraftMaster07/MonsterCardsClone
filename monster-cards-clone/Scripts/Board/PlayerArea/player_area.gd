class_name PlayerArea
extends Control

@onready var field: Field = $Field
@onready var deck: Deck = $Deck


func get_field():
    return field


func get_deck():
    return deck
