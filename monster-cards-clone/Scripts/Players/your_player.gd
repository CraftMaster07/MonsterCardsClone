class_name YourPlayer
extends Player


signal new_card_added(card: HandCard)


func set_hand(new_hand: Hand):
	super.set_hand(new_hand)
	hand.new_card_added.connect(_on_hand_new_card_added)


func draw_card():
	# we need to get the card data from the server
	pass


func _on_hand_new_card_added(card: HandCard):
	new_card_added.emit(card)


func shadow_deserialize(serialized_shadow_player_data: Dictionary):
	hand.shadow_deserialize(serialized_shadow_player_data["hand"])
	
