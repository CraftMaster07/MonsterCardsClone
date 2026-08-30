class_name EditorCardContainer
extends VBoxContainer

var card: EditorCard
var amount: int = 1
@export var label: Label

signal card_decremented(card_name: String)


func add_card(new_card: EditorCard) -> void:
	card = new_card
	add_child(card)
	move_child(card, 0)
	card.card_selected.connect(card_selected)


func update_label() -> void:
	label.text = str(amount)


func card_selected(_card) -> void:
	card_decremented.emit(card.get_file_name())


func reduce_amount() -> void:
	amount -= 1
	update_label()


func increase_amount() -> void:
	amount += 1
	update_label()


func set_amount(new_amount: int) -> void:
	amount = new_amount
	update_label()
