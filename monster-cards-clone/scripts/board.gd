extends Control

@onready var hand := $Hand
@export var card_board_scene : PackedScene

func _ready() -> void:
	for card in hand.cards_container.get_children():
		card.card_placed.connect(place_card)
	
	


func place_card(card):
	print("card placed")
	var new_card_board := card_board_scene.instantiate()
	add_child(new_card_board) #temporary, should add underneath some container and not directly
	new_card_board.global_position = card.card_front.global_position
	card.queue_free()
