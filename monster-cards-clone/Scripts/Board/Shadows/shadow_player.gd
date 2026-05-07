class_name ShadowPlayer
extends Node


var player_id: int
var deck: ShadowDeck
var hand: ShadowHand


func _init(new_player_id):
	player_id = new_player_id
	deck = ShadowDeck.new()
	hand = ShadowHand.new()
	add_child(deck)
	add_child(hand)


func create_player_deck(serialized_deck_blueprint: Dictionary):
	deck.create_deck(serialized_deck_blueprint, player_id)


func draw_card() -> bool:
	var drawn_card = deck.draw_card_data()

	if drawn_card:
		hand.add_card_data(drawn_card)

	return drawn_card != null


func shadow_serialize() -> Dictionary:
	return {
		"hand": hand.shadow_serialize()
	}


func remove_hand_card_by_uuid(card_uuid: String):
	hand.remove_card_data(card_uuid, false)


func get_deck_card_data_count() -> int:
	return deck.get_card_data_count()


func get_hand_card_data_count() -> int:
	return hand.get_card_data_count()


func get_hand_card_data_by_uuid(card_uuid: String) -> CardData:
	return hand.get_card_data_by_uuid(card_uuid)
