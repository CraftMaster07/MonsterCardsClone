class_name EditorCard
extends Control

var card_file: CardFile = CardFile.new()
@export var card_front: CardFront


signal card_selected(card: EditorCard)


func _ready():
	update_display()


func get_health() -> int:
	return card_file.health


func set_health(health: int) -> void:
	card_file.health = health
	set_display_health(health)


func get_attack() -> int:
	return card_file.attack


func set_attack(attack: int) -> void:
	card_file.attack = attack
	set_display_attack(attack)


func get_cost() -> int:
	return card_file.cost


func set_cost(cost: int) -> void:
	card_file.cost = cost
	set_display_cost(cost)


func get_card_name() -> String:
	return card_file.card_name


func set_card_name(card_name: String) -> void:
	card_file.card_name = card_name


func save():
	card_file.save()


func load(card_path: String) -> void:
	card_file.load(card_path)
	update_display()


func update_display():
	if not is_node_ready():
		return

	set_display_health(card_file.health)
	set_display_attack(card_file.attack)
	set_display_cost(card_file.cost)


func set_display_health(health: int) -> void:
	card_front.set_initial_health(health)


func set_display_attack(attack: int) -> void:
	card_front.set_initial_attack(attack)


func set_display_cost(cost: int) -> void:
	card_front.set_initial_cost(cost)


func _on_card_front_pressed() -> void:
	card_selected.emit(self)


func serialize() -> Dictionary:
	return {
		"card_file": card_file.serialize()
	}


func deserialize(data: Dictionary) -> void:
	card_file.deserialize(data["card_file"])
	update_display()