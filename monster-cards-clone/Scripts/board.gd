extends Node2D

var selected_card : Card
@onready var hand := $Hand

func _ready() -> void:
	for card in hand.get_children():
		card.connect("card_selected", select_card)

func _process(delta: float) -> void:
	print(selected_card)

func select_card(card):
	if selected_card == card:
		selected_card = null
	else:
		selected_card = card
