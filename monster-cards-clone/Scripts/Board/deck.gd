extends Control

@export var deck_card_scene: PackedScene


func draw_card():
    if get_child_count() > 0:
        remove_card()
        return true
    return false


func add_cards(cards_count: int):
    for i in range(cards_count):
        add_card()


func add_card():
    var new_card = deck_card_scene.instantiate()
    add_child(new_card)


func remove_cards(cards_count: int):
    for i in range(cards_count):
        remove_card()


func remove_card():
    if get_child_count() == 0:
        push_error("There are no cards in the deck")

    var drawn_card = get_child(0)
    remove_child(drawn_card)
    drawn_card.queue_free()


func serialize():
    return {"cards_count": get_child_count()}


func deserialize(data: Dictionary):
    var card_diff = data["cards_count"] - get_child_count()

    if card_diff > 0:
        add_cards(card_diff)
    elif card_diff < 0:
        remove_cards(-card_diff)
