class_name Player
extends Control

var player_name: String
var player_id: int

const STARTING_HEALTH: int = 20
const STARTING_MANA: int = 0
var health: int
var mana: int
var deck: Deck
var field: Field
var hand: Hand

var attacking_id: int = 0
var attacked_by_id: int = 0

@onready var label: Label = $HealthLabel


func init(new_player_id: int, new_player_name: String):
	player_id = new_player_id
	player_name = new_player_name
	health = STARTING_HEALTH
	mana = STARTING_MANA


func _ready():
	update_stats_label()


func take_damage(amount: int) -> void:
	print("ouch!")
	decrease_health(amount)


func decrease_health(amount: int) -> void:
	health -= amount
	update_stats_label()


func update_stats_label() -> void:
	label.text = player_name + ": " + str(health) + "\\" + str(STARTING_HEALTH) + ", " + str(mana)


func get_field() -> Field:
	return field


func set_field(new_field: Field):
	field = new_field


func is_slot_taken(slot_id: int) -> bool:
	return field.is_slot_taken(slot_id)


func get_slot_id(slot: EnemyCardSlot) -> int:
	return field.get_slot_id(slot)


func serialize():
	return {
		"player_id": player_id,
		"player_name": player_name,
		"health": health,
		"mana": mana,
		"field": field.serialize(),
		"deck": deck.serialize(),
		"hand": hand.serialize(),
	}


func deserialize(serialized_player: Dictionary):
	player_id = serialized_player['player_id']
	player_name = serialized_player['player_name']
	health = serialized_player['health']
	mana = serialized_player['mana']
	update_stats_label()
	field.deserialize(serialized_player['field'])
	deck.deserialize(serialized_player['deck'])
	hand.deserialize(serialized_player['hand'])


func place_serialized_card_into_slot(serialized_card: Dictionary, slot_id: int):
	field.place_serialized_card_into_slot(serialized_card, slot_id)


func get_id():
	return player_id


func exorcise():
	field.exorcise()


func set_deck(new_deck: Deck):
	deck = new_deck


func add_cards_to_deck(cards_count: int):
	deck.add_cards(cards_count)


func set_hand(new_hand: Hand):
	hand = new_hand


func draw_card() -> bool:
	return deck.draw_card()


func update_hand(hand_card_count: int):
	hand.update_cards(hand_card_count)


func add_mana(mana_count: int):
	mana += mana_count


func can_spend_mana(mana_count: int) -> bool:
	return mana - mana_count >= 0


func spend_mana(mana_count: int):
	if mana - mana_count < 0:
		push_error("not enough mana")

	mana -= mana_count
	update_stats_label()
