class_name DeckContainer
extends HBoxContainer

@export var card_container_scene: PackedScene
var card_containers: Dictionary[String, EditorCardContainer] = {}

signal card_decremented(card_name: String)
signal updated_size(card_count: int)

func add_card_container(card_name: String, card: EditorCard) -> void:
	var card_container = card_container_scene.instantiate()
	card_container.add_card(card)
	add_child(card_container)
	card_container.card_decremented.connect(card_amount_decremented)
	card_containers[card_name] = card_container
	update_size_label()


func remove_card_container(card_name: String) -> void:
	card_containers[card_name].queue_free()
	card_containers.erase(card_name)
	update_size_label()


func increment_card_amount(card_name: String) -> void:
	card_containers[card_name].increase_amount()
	update_size_label()


func decrement_card_amount(card_name: String) -> void:
	card_containers[card_name].reduce_amount()
	update_size_label()


func card_amount_decremented(card_name: String) -> void:
	card_decremented.emit(card_name)
	update_size_label()


func update_card_amount(card_name: String, amount: int) -> void:
	card_containers[card_name].set_amount(amount)
	update_size_label()


func update_size_label() -> void:
	var sum: int = 0

	for card_container in card_containers.values():
		sum += card_container.amount

	updated_size.emit(sum)