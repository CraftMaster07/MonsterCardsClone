class_name Player
extends Control

var player_name: String
var player_id: int

const STARTING_HEALTH: int = 20
const STARTING_MANA: int = 1
var health: int
var max_health: int
var mana: int

var area: PlayerArea
var deck: Deck
var field: Field
var hand: Hand
var health_icon: StatIcon
var mana_icon: StatIcon

var attacking_id: int = 0
var attacked_by_id: int = 0


const TRIGGER_ID = Trigger.TriggerID
var triggers_to_signals: Dictionary = {
	TRIGGER_ID.DRAW_CARD: drawn_card,
	TRIGGER_ID.ON_FACE_DAMAGED: on_face_damaged,
}

signal drawn_card
signal on_face_damaged


func init(new_player_id: int, new_player_name: String):
	player_id = new_player_id
	player_name = new_player_name
	health = STARTING_HEALTH
	max_health = STARTING_HEALTH
	mana = STARTING_MANA


func set_health(value: int):
	health = value
	update_health_icon()


func heal(amount: int):
	set_health(min(health + amount, max_health))


func take_damage(amount: int) -> void:
	set_health(health - amount)

	if amount > 0:
		player_trigger(TRIGGER_ID.ON_FACE_DAMAGED)


func set_mana(value: int):
	mana = value
	update_mana_icon()


func add_mana(mana_amount: int):
	set_mana(mana + mana_amount)


func can_spend_mana(mana_count: int) -> bool:
	return mana - mana_count >= 0


func spend_mana(mana_count: int):
	if !can_spend_mana(mana_count):
		push_error("not enough mana")

	set_mana(mana - mana_count)


func reset_mana():
	set_mana(0)


func set_health_icon(new_health_icon: StatIcon):
	health_icon = new_health_icon
	update_health_icon()
	

func set_mana_icon(new_mana_icon: StatIcon):
	mana_icon = new_mana_icon
	update_mana_icon()


func update_health_icon():
	health_icon.update_label(str(health) + "/" + str(STARTING_HEALTH))


func update_mana_icon():
	mana_icon.update_label(str(mana))


func get_area_rotation() -> float:
	return area.rotation


func set_area(new_area: PlayerArea):
	area = new_area


func get_field() -> Field:
	return field


func set_field(new_field: Field):
	field = new_field


func is_slot_taken(slot_id: int) -> bool:
	return field.is_slot_taken(slot_id)


func get_slot_id(slot: CardSlot) -> int:
	return field.get_slot_id(slot)


func serialize():
	return {
		"player_id": player_id,
		"player_name": player_name,
		"health": health,
		"max_health": max_health,
		"mana": mana,
		"field": field.serialize(),
		"deck": deck.serialize(),
		"hand": hand.serialize(),
	}


func deserialize(serialized_player: Dictionary):
	player_id = serialized_player['player_id']
	player_name = serialized_player['player_name']
	max_health = serialized_player['max_health']
	set_health(serialized_player['health'])
	set_mana(serialized_player['mana'])
	field.deserialize(serialized_player['field'])
	deck.deserialize(serialized_player['deck'])
	hand.deserialize(serialized_player['hand'])


func place_card_into_slot(card: BoardCard, slot_id: int) -> BoardCard:
	return field.place_card_into_slot(card, slot_id)


func get_id():
	return player_id


func exorcise() -> bool:
	return field.exorcise()


func set_deck(new_deck: Deck):
	deck = new_deck


func add_cards_to_deck(cards_count: int):
	deck.add_cards(cards_count)


func set_hand(new_hand: Hand):
	hand = new_hand


func draw_card() -> bool:
	player_trigger(TRIGGER_ID.DRAW_CARD)
	return deck.draw_card()


func update_hand(hand_card_count: int):
	hand.update_cards(hand_card_count)


func player_trigger(trigger_id):
	print(player_id, ": triggering player trigger: ", trigger_id)
	triggers_to_signals[trigger_id].emit()


func get_random_board_card_data() -> CardData:
	return field.get_random_card_data()
