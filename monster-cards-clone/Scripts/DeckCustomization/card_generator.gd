class_name CardGenerator
extends Node

static var example_cards: Array[Dictionary] = [
	{"attack":1,"card_name":"Ex_Card1","cost":1,"health":2,"serialized_sprite":{}},
	{"attack":3,"card_name":"Ex_Card2","cost":2,"health":1,"serialized_sprite":{}},
	{"attack":2,"card_name":"Ex_Card3","cost":2,"health":3,"serialized_sprite":{}},
	{"attack":4,"card_name":"Ex_Card4","cost":5,"health":5,"serialized_sprite":{}},
	{"attack":3,"card_name":"Ex_Card5","cost":5,"health":7,"serialized_sprite":{}},
	{"attack":7,"card_name":"Ex_Card6","cost":7,"health":3,"serialized_sprite":{}}
]


static var example_decks: Array[Dictionary] = [
	{"cards":{"Ex_Card1":3,"Ex_Card2":4,"Ex_Card3":4,"Ex_Card4":4,"Ex_Card5":3,"Ex_Card6":2},"name":"Ex_Deck1"},
]


static func generate_card(card_name: String, file_name: String, health: int, attack: int, cost: int) -> CardFile:
	var card_file := CardFile.new()
	card_file.set_name(card_name)
	card_file.file_name = file_name
	card_file.health = health
	card_file.attack = attack
	card_file.cost = CardEditor.calculate_cost(health, attack)
	return card_file


static func generate_card_to_file(card_name: String, file_name: String, health: int, attack: int, cost: int):
	var card_file := generate_card(card_name, file_name, health, attack, cost)
	card_file.save()
	return card_file


static func generate_example_cards():
	for card in example_cards:
		generate_card_to_file(card["card_name"], card["card_name"], card["health"], card["attack"], card["cost"])


static func generate_deck(deck_name: String, deck_cards: Dictionary):
	var deck_file := DeckFile.new()
	deck_file.name = deck_name
	deck_file.cards = deck_cards
	deck_file.save()


static func generate_example_decks():
	for deck in example_decks:
		var deck_file := DeckFile.new()
		deck_file.name = deck["name"]
		deck_file.cards = deck["cards"]
		deck_file.save()
	

static func generate_example_pack():
	generate_example_cards()
	generate_example_decks()
