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


func get_file_name() -> String:
	return card_file.file_name


func set_card_name(card_name: String) -> void:
	card_file.set_name(card_name)


func save():
	card_file.save()


func load(card_path: String) -> bool:
	var status: bool = card_file.load(card_path)
	update_display()
	return status


func update_display():
	if not is_node_ready():
		return

	set_display_health(card_file.health)
	set_display_attack(card_file.attack)
	set_display_cost(card_file.cost)

	set_display_ability_signature()


func set_display_health(health: int) -> void:
	card_front.set_initial_health(health)


func set_display_attack(attack: int) -> void:
	card_front.set_initial_attack(attack)


func set_display_cost(cost: int) -> void:
	card_front.set_initial_cost(cost)


func set_display_ability_signature() -> void:
	card_front.show_ability_signature(has_ability())


func _on_card_front_pressed() -> void:
	card_selected.emit(self)


func serialize() -> Dictionary:
	return {
		"card_file": card_file.serialize()
	}


func deserialize(data: Dictionary) -> void:
	card_file.deserialize(data["card_file"])
	update_display()


func set_effect(effect: Effect) -> void:
	card_file.set_effect(effect)
	update_display()


func set_trigger(trigger: Trigger) -> void:
	card_file.set_trigger(trigger)


func get_effect() -> Effect:
	return card_file.get_effect()


func get_trigger() -> Trigger:
	return card_file.get_trigger()


func has_ability() -> bool:
	return card_file.has_ability()


func remove_ability():
	card_file.remove_ability()
	update_display()
