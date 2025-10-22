extends Control

@onready var hand := $Hand
@export var card_board_scene : PackedScene

func _ready() -> void:
	for card in hand.cards_container.get_children():
		if card is not CardHand:
			print_rich("what the [b][color=red]fuck[/color][/b]? this is not a card")
		else:
			card.card_placed.connect(place_card_into_slot)

func place_card_into_slot(card : CardHand, slot : CardSlot):
	print("card placed")
	slot.take()
	card.goto_slot(slot)
	card.tween.tween_callback(replace_cardhand_with_cardboard.bind(card))

func replace_cardhand_with_cardboard(card : CardHand):
	var new_card_board := card_board_scene.instantiate()
	add_child(new_card_board) #temporary, should add underneath some container and not directly
	new_card_board.global_position = card.card_front.global_position
	card.queue_free()
