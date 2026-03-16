extends Board


var shadow_player_manager: ShadowPlayerManager

signal call_sync_game(game_state: Dictionary)
signal call_shadow_sync(player_id: int, serialized_shadow_player_data: Dictionary)
signal request_deck_blueprints()
signal received_all_deck_blueprints()


func _ready():
	create_shadow_players()
	get_remote_decks()

	await received_all_deck_blueprints

	super._ready()

	init_player_boards()

	round_manager.next_turn()
	send_game_state()


func create_shadow_players():
	shadow_player_manager = ShadowPlayerManager.new()

	for player_id in player_manager.get_player_ids():
		var shadow_player = ShadowPlayer.new(player_id)
		shadow_player_manager.add_player(shadow_player)


func get_remote_decks():
	player_ids_without_deck_blueprint = shadow_player_manager.get_player_ids()
	request_deck_blueprints.emit()


func client_deck_blueprint_received(player_id: int, deck_blueprint: Dictionary):
	# TODO: add verifications
	shadow_player_manager.create_player_deck(deck_blueprint, player_id)
	player_ids_without_deck_blueprint.erase(player_id)

	if len(player_ids_without_deck_blueprint) == 0:
		print("all deck blueprints received")
		received_all_deck_blueprints.emit()


func client_attacked(player_id: int, attacked_id: int):
	if phase != Phase.COMBAT:
		return
	if player_id != round_manager.current_player_id:
		return

	var err: Error = player_manager.do_player_attack(player_id, attacked_id)
	if err != Error.OK:
		return

	combat(player_id, attacked_id)

	round_manager.client_ended_turn(player_id)
	send_game_state()


func draw_card(player_id: int):
	var success: bool = shadow_player_manager.draw_card(player_id)
	
	if success:
		player_manager.draw_card(player_id)
	else:
		push_error("draw card failed")


func client_ended_turn(player_id: int):
	round_manager.client_ended_turn(player_id)
	send_game_state()


func _on_round_manager_started_turn(player_id: int) -> void:
	super._on_round_manager_started_turn(player_id)
	
	if phase == Phase.PREP:
		draw_card(player_id)


func send_game_state():
	call_sync_game.emit(get_game_state())
	send_shadow_players()


func get_game_state() -> Dictionary:
	return {"players": player_manager.serialize(),
			"round_manager": round_manager.serialize(),
			"phase": phase}
	# add last_action for animations


func send_shadow_players():
	for player_id in shadow_player_manager.get_player_ids():
		send_shadow_player(player_id)


func send_shadow_player(player_id: int):
	call_shadow_sync.emit(player_id, shadow_player_manager.shadow_serialize_player(player_id))


func client_placed_card(player_id: int, serialized_card: Dictionary, slot_id: int):
	var status := verify_card_placement(player_id, slot_id)
	match status:
		ValidationResponses.OK:
			player_manager.place_serialized_card_into_slot(player_id, serialized_card, slot_id)
			shadow_player_manager.remove_serialized_card_from_hand(player_id, serialized_card)
		ValidationResponses.SLOT_TAKEN:
			print("slot taken: (Player: ", player_id, ", Slot: ", slot_id, ")")
		ValidationResponses.NOT_YOUR_TURN:
			print("not his turn (Player: ", player_id, ")")
		ValidationResponses.NOT_IN_PREP:
			print("not in prep phase (Player: ", player_id, ")")
		ValidationResponses.INVALID:
			print("unexpected error occured (Player: ", player_id, ", Slot: ", slot_id, ")")

	send_game_state()


func _replace_handcard_with_boardcard(card: HandCard, slot: EnemyCardSlot):
	super._replace_handcard_with_boardcard(card, slot)
	shadow_player_manager.remove_serialized_card_from_hand(your_id, card.serialize())


func init_player_boards():
	"""
	Initializes things on the board.
	"""
	add_initial_deck_cards()
	draw_initial_cards()
	print("initial cards drawn")


func add_initial_deck_cards():
	for player_id in player_manager.get_player_ids():
		player_manager.add_cards_to_deck(player_id, shadow_player_manager.get_deck_card_data_count(player_id))


func draw_initial_cards():
	for player_id in player_manager.get_player_ids():
		for i in range(INITIAL_HAND_CARD_COUNT):
			draw_card(player_id)


func _on_round_manager_round_ended() -> void:
	super._on_round_manager_round_ended()
	send_game_state()


func remove_player(player_id: int):
	super.remove_player(player_id)
	send_game_state()


func _on_button_pressed() -> void:
	send_game_state()


# func update_enemy_hands():
# 	for player_id in shadow_player_manager.get_player_ids():
