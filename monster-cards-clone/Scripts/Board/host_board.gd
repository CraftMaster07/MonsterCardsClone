extends Board

const TRIGGER_ID = Trigger.TriggerID
const EFFECT_ID =  Effect.EffectID
const TARGET_ID = Effect.TARGET

var shadow_player_manager: ShadowPlayerManager

@export var ability_manager: AbilityManager

signal call_sync_game(game_state: Dictionary)
signal call_shadow_sync(player_id: int, serialized_shadow_player_data: Dictionary)
signal request_deck_blueprints()
signal received_all_deck_blueprints()
signal send_missing_sprite(player_id: int, serialized_sprite: Dictionary, callback_uuid: String)

var effect_to_funcs: Dictionary = {
	EFFECT_ID.HEAL: heal,
	EFFECT_ID.ATTACK_BUFF: buff_attack,
	EFFECT_ID.DRAW_CARD: draw_card,
	EFFECT_ID.DAMAGE: damage,
}

var target_to_funcs: Dictionary = {
	TARGET_ID.SELF: fetch_target_self,
	TARGET_ID.FACE: fetch_target_face,
	TARGET_ID.RANDOM_ENEMY_CARD: fetch_target_random_enemy_card,
	TARGET_ID.RANDOM_ENEMY_FACE: fetch_target_random_enemy_face
}


func _ready():
	create_shadow_players()
	get_remote_decks()

	await received_all_deck_blueprints

	super._ready()

	init_player_boards()

	round_manager.advance_round_number()
	round_manager.next_turn()

	send_game_state()


func create_shadow_players():
	shadow_player_manager = ShadowPlayerManager.new()
	add_child(shadow_player_manager)

	for player_id in player_manager.get_player_ids():
		var shadow_player = ShadowPlayer.new(player_id)
		shadow_player_manager.add_player(shadow_player)


func get_remote_decks():
	player_ids_without_deck_blueprint = shadow_player_manager.get_player_ids()
	request_deck_blueprints.emit()


func client_deck_blueprint_received(player_id: int, deck_blueprint: Dictionary):
	var serialized_sprites: Dictionary = deck_blueprint["sprites"]

	for sprite_hash in serialized_sprites:
		if not CardSpriteManager.has_sprite(sprite_hash):
			var calculated_hash = CardSpriteManager.add_sprite(serialized_sprites[sprite_hash])

			if sprite_hash != calculated_hash:
				push_error("(player_id: {0}) sprite hashes not matching ({1} != {2})".format(
					[player_id, calculated_hash, sprite_hash]
				))

	# TODO: add verifications
	shadow_player_manager.create_player_deck(deck_blueprint, player_id)
	player_ids_without_deck_blueprint.erase(player_id)

	if len(player_ids_without_deck_blueprint) == 0:
		print("all deck blueprints received")
		received_all_deck_blueprints.emit()


func combat(attacker_id: int, attacked_id: int):
	var attacker := player_manager.get_player(attacker_id)
	var attacked := player_manager.get_player(attacked_id)

	var attacker_field := attacker.get_field()
	var attacked_field := attacked.get_field()

	for i in range(attacker_field.get_slot_count()):
		var attacker_card = attacker_field.get_card(i)
		var attacked_card = attacked_field.get_card(i)

		if not attacker_card:
			continue
		elif not attacked_card:
			attacker_card.hit(attacked)
		else:
			attacker_card.hit(attacked_card)


func client_attacked(player_id: int, attacked_id: int):
	# TODO: add verifications
	var status: CombatValidationResponses = verify_attack(player_id, attacked_id)

	if status != CombatValidationResponses.OK:
		print("invalid attack, status: ", status)
		return

	combat(player_id, attacked_id)

	round_manager.client_ended_turn(player_id)
	send_game_state()


func draw_card_to_player(player_id: int):
	var success: bool = shadow_player_manager.draw_card(player_id)

	if success:
		player_manager.draw_card(player_id)
	else:
		print(str(player_id),": draw card failed")


func client_ended_turn(player_id: int):
	round_manager.client_ended_turn(player_id)
	send_game_state()


func send_game_state():
	send_shadow_player(your_id)
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


func client_placed_card(player_id: int, card_uuid: String, slot_id: int):
	var card_data: CardData = shadow_player_manager.get_hand_card_data_by_uuid(player_id, card_uuid)

	if not card_data:
		print("card not in hand (Player: ", player_id, ", Card: ", card_uuid, ")")
		send_game_state()
		return
	
	var status := verify_card_placement(player_id, slot_id, card_data)

	match status:
		ValidationResponses.OK:
			# This doesnt happen when the host places a card
			place_client_card(player_id, card_data, slot_id)
		ValidationResponses.SLOT_TAKEN:
			print("slot taken: (Player: ", player_id, ", Slot: ", slot_id, ")")
		ValidationResponses.NOT_YOUR_TURN:
			print("not his turn (Player: ", player_id, ")")
		ValidationResponses.NOT_IN_PREP:
			print("not in prep phase (Player: ", player_id, ")")
		ValidationResponses.NOT_ENOUGH_MANA:
			print("not enough mana (Player: ", player_id, ")")
		ValidationResponses.INVALID:
			print("unexpected error occured (Player: ", player_id, ", Slot: ", slot_id, ")")

	update_enemy_hands()
	send_game_state()


func place_client_card(player_id: int, card_data: CardData, slot_id: int):
	shadow_player_manager.remove_hand_card_by_uuid(player_id, card_data.uuid)
	var card := create_board_card(card_data)
	player_manager.place_card_into_slot(player_id, card, slot_id)
	player_manager.spend_mana(player_id, card_data.cost)
	integrate_client_card(player_id, card_data)


func integrate_client_card(player_id: int, card_data: CardData):
	subscribe_card(card_data, player_manager.get_player(player_id))
	
	if card_data.get_trigger_id() == TRIGGER_ID.WHEN_PLAYED:
		card_data.run_ability()


func _replace_handcard_with_boardcard(card: HandCard, slot: CardSlot):
	super._replace_handcard_with_boardcard(card, slot)
	shadow_player_manager.remove_hand_card_by_uuid(your_id, card.get_card_data().uuid)
	integrate_client_card(your_id, card.get_card_data())


func init_player_boards():
	"""
	Initializes things on the board.
	"""
	for player_id in player_manager.get_player_ids():
		add_initial_deck_cards(player_id)
		draw_initial_cards(player_id)

	print("initial cards drawn")


func add_initial_deck_cards(player_id: int):
	player_manager.add_cards_to_deck(player_id, shadow_player_manager.get_deck_card_data_count(player_id))


func draw_initial_cards(player_id: int):
	for i in range(INITIAL_HAND_CARD_COUNT):
		draw_card_to_player(player_id)


func draw_card_for_each_player():
	for player_id in player_manager.get_player_ids():
		draw_card_to_player(player_id)


func _on_round_manager_round_ended() -> void:
	super._on_round_manager_round_ended()

	if phase == Phase.PREP:
		reset_players_mana()
		add_round_mana_for_each_player()
		draw_card_for_each_player()
		round_manager.move_first_player_to_last()
		trigger_round_start_abilities()

	send_game_state()


func remove_player(player_id: int):
	super.remove_player(player_id)
	send_game_state()


func update_enemy_hands():
	var player_ids = shadow_player_manager.get_player_ids()
	player_ids.erase(your_id)

	for player_id in player_ids:
		var hand_card_count: int = shadow_player_manager.get_hand_card_data_count(player_id)
		player_manager.update_hand(player_id, hand_card_count)


func add_round_mana(player_id: int):
	var mana_amount: int = round_manager.get_round_number()
	player_manager.add_mana(player_id, mana_amount)


func add_round_mana_for_each_player():
	for player_id in player_manager.get_player_ids():
		add_round_mana(player_id)


func reset_players_mana():
	for player_id in player_manager.get_player_ids():
		player_manager.reset_mana(player_id)


func subscribe_card(card: CardData, player: Player):
	if not card.has_ability():
		return

	ability_manager.subscribe_card(card, player)


func trigger_round_start_abilities():
	ability_manager.board_trigger(TRIGGER_ID.ROUND_START)


func _on_ability_manager_activate(effect: Effect, card: CardData, player: Player) -> void:
	effect_to_funcs[effect.get_id()].call(effect, card, player)
	send_game_state()


func heal(effect: Effect, card: CardData, player: Player):
	apply_numbered_effect("heal", effect, card, player)


func buff_attack(effect: Effect, card: CardData, player: Player):
	apply_numbered_effect("buff_attack", effect, card, player)


func draw_card(_effect: Effect, _card: CardData, player: Player):
	draw_card_to_player(player.get_id())


func damage(effect: Effect, card: CardData, player: Player):
	apply_numbered_effect("take_damage", effect, card, player)
	if phase != Phase.COMBAT:
		exorcise()


func fetch_target(target: Effect.TARGET, effect: Effect, card: CardData, player: Player):
	return target_to_funcs[target].call(effect, card, player)


func fetch_target_self(_effect: Effect, card: CardData, _player: Player):
	return card


func fetch_target_face(_effect: Effect, _card: CardData, player: Player):
	return player


func fetch_target_random_enemy_face(_effect: Effect, _card: CardData, player: Player):
	return player_manager.get_random_enemy_player(player.get_id())


func fetch_target_random_enemy_card(effect: Effect, card: CardData, player: Player):
	return fetch_target_random_enemy_face(effect, card, player).get_random_board_card_data()


func apply_numbered_effect(method: String, effect: Effect, card: CardData, player: Player):
	var target: Effect.TARGET = effect.get_target()
	var amount: int = effect.get_property("amount")

	var chosen_target = fetch_target(target, effect, card, player)
	if not chosen_target: return
	chosen_target.callv(method, [amount])


func get_missing_sprite(player_id: int, sprite_hash: String, callback_uuid: String):
	var serialized_sprite = CardSpriteManager.get_serialized_sprite(sprite_hash)

	if serialized_sprite:
		send_missing_sprite.emit(player_id, serialized_sprite, callback_uuid)
	else:
		push_warning("missing sprite: ", sprite_hash)