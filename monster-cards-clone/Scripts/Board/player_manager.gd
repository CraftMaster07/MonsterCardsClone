class_name PlayerManager
extends Node

signal player_attacked(player_id: int)

@export var your_player_scene: PackedScene
@export var enemy_player_scene: PackedScene
@export var player_container: VBoxContainer

var players: Dictionary[int, Player] = {}
var your_id: int

var original_player_count: int

func get_player_count():
	return len(players)


func get_original_player_count():
	return original_player_count


func get_player_ids() -> Array:
	return players.keys()


func get_player(player_id: int) -> Player:
	return players[player_id]


func init_players(multiplayer_players: Array):
	for player_data in multiplayer_players:
		if player_data['id'] == your_id:
			init_your_player(player_data)
		else:
			init_enemy_player(player_data)
	original_player_count = get_player_count()


func init_enemy_player(player_data: Dictionary):
	var new_player: Player = enemy_player_scene.instantiate()
	new_player.init(player_data['id'], player_data['name'])
	player_container.add_child(new_player)
	players[player_data['id']] = new_player


func init_your_player(player_data: Dictionary):
	var new_player: Player = your_player_scene.instantiate()
	new_player.init(player_data['id'], player_data['name'])
	player_container.add_child(new_player)
	players[player_data['id']] = new_player


func remove_player(id: int):
	remove_child(players[id])
	players[id].queue_free()
	players.erase(id)


func serialize():
	var serialized_players := {}

	for player in players.values():
		serialized_players[player.player_id] = (player.serialize())

	return serialized_players


func deserialize(serialized_players: Dictionary):
	for serialized_player_id in serialized_players:
		players[serialized_player_id].deserialize(serialized_players[serialized_player_id])


func get_unassigned_area_player_ids():
	var unassigned_area_player_ids := []

	for player in players.values():
		if player.player_id == your_id:
			continue

		if player.get_field() == null or player.get_deck() == null:
			unassigned_area_player_ids.append(player.player_id)

	return unassigned_area_player_ids


func set_player_area(area: PlayerArea, player_id: int):
	get_player(player_id).set_area(area)


func set_player_field(field: Field, player_id: int):
	get_player(player_id).set_field(field)


func set_player_deck(deck: Deck, player_id: int):
	get_player(player_id).set_deck(deck)


func set_player_hand(hand: Hand, player_id: int):
	get_player(player_id).set_hand(hand)


func set_player_attack_button(attack_button: Button, player_id: int):
	print("player_id: ", player_id)
	var player = get_player(player_id)
	player.set_attack_button(attack_button)
	player.attacked.connect(on_enemy_player_attacked)
	

func set_player_health_icon(health_icon: StatIcon, player_id: int):
	get_player(player_id).set_health_icon(health_icon)
	

func set_player_mana_icon(mana_icon: StatIcon, player_id: int):
	get_player(player_id).set_mana_icon(mana_icon)


func set_your_id(id: int):
	your_id = id


func on_enemy_player_attacked(player_id: int):
	player_attacked.emit(player_id)


func record_player_attack(attacker_id: int, attacked_id: int) -> Error:
	if check_attacked(attacker_id) or check_was_attacked(attacked_id):
		print("invalid attack")
		return FAILED

	set_attacked(attacker_id, attacked_id)
	set_was_attacked(attacked_id, attacker_id)
	return OK


func check_attacked(player_id: int) -> bool:
	return get_player(player_id).attacking_id != 0


func set_attacked(attacker_id: int, attacked_id: int):
	get_player(attacker_id).attacking_id = attacked_id


func check_was_attacked(player_id: int) -> bool:
	return get_player(player_id).attacked_by_id != 0


func set_was_attacked(attacked_id: int, attacker_id: int):
	get_player(attacked_id).attacked_by_id = attacker_id


func reset_attack_history():
	for player in players.values():
		player.attacking_id = 0
		player.attacked_by_id = 0


func exorcise() -> bool:
	var was_ability_activated: bool = false

	for player in players.values():
		if player.exorcise():
			was_ability_activated = true

	return was_ability_activated


func draw_card(player_id: int):
	get_player(player_id).draw_card()


func add_cards_to_deck(player_id: int, cards_count: int):
	get_player(player_id).add_cards_to_deck(cards_count)


func get_your_player():
	return get_player(your_id)


func shadow_deserialize(serialized_shadow_player_data: Dictionary):
	get_your_player().shadow_deserialize(serialized_shadow_player_data)


func place_card_into_slot(player_id: int, card: BoardCard, slot_id: int) -> BoardCard:
	return get_player(player_id).place_card_into_slot(card, slot_id)


func update_hand(player_id: int, hand_card_count: int):
	get_player(player_id).update_hand(hand_card_count)


func get_slot_id(player_id: int, slot: CardSlot):
	return get_player(player_id).get_slot_id(slot)


func add_mana(player_id: int, mana: int):
	get_player(player_id).add_mana(mana)


func can_spend_mana(player_id: int, mana: int):
	return get_player(player_id).can_spend_mana(mana)


func spend_mana(player_id: int, mana: int):
	get_player(player_id).spend_mana(mana)


func reset_mana(player_id: int):
	get_player(player_id).reset_mana()


func get_area_rotation(player_id: int) -> float:
	return get_player(player_id).get_area_rotation()


func get_random_enemy_player(player_id: int) -> Player:
	var player_ids := get_player_ids()
	player_ids.erase(player_id)
	return get_player(player_ids[randi() % player_ids.size()])


func show_attack_buttons():
	for player in players.values():
		if is_instance_of(player, YourPlayer):
			continue

		player.show_attack_button()


func hide_attack_buttons():
	for player in players.values():
		if is_instance_of(player, YourPlayer):
			continue

		player.hide_attack_button()
