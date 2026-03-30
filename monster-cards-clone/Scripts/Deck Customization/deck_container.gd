class_name DeckContainer
extends HBoxContainer

@export var card_container_scene: PackedScene
var card_containers: Dictionary[String, EditorCardContainer] = {}

signal card_decremented(card_name: String)

func add_card_container(card_name: String, card: EditorCard) -> void:
	var card_container = card_container_scene.instantiate()
	card_container.add_card(card)
	add_child(card_container)
	card_container.card_decremented.connect(card_amount_decremented)
	card_containers[card_name] = card_container


func remove_card_container(card_name: String) -> void:
	card_containers[card_name].queue_free()
	card_containers.erase(card_name)


func increment_card_amount(card_name: String) -> void:
	card_containers[card_name].increase_amount()


func decrement_card_amount(card_name: String) -> void:
	card_containers[card_name].reduce_amount()


func card_amount_decremented(card_name: String) -> void:
	card_decremented.emit(card_name)


func update_card_amount(card_name: String, amount: int) -> void:
	card_containers[card_name].set_amount(amount)
