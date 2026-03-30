class_name CardFront
extends TextureButton

@export var name_label: RichTextLabel
@export var health_label: RichTextLabel
@export var attack_label: RichTextLabel
@export var cost_label: RichTextLabel

var initial_health: int = -1
var initial_attack: int = -1
var initial_cost: int = -1


func set_initial_values(card_data: CardData) -> void:
	set_card_name(card_data.card_name)
	set_initial_health(card_data.health)
	set_initial_attack(card_data.attack)
	set_initial_cost(card_data.cost)
	update_labels(card_data)


func set_card_name(card_name: String) -> void:
	name_label.text = card_name


func set_initial_health(health: int) -> void:
	initial_health = health
	update_health(health)


func set_initial_attack(attack: int) -> void:
	initial_attack = attack
	update_attack(attack)


func set_initial_cost(cost: int) -> void:
	initial_cost = cost
	update_cost(cost)


func update_health(health: int) -> void:
	if health != initial_health:
		health_label.text = ColorConstants.RED_TEXT.format([str(health)])
	else:
		health_label.text = str(health)


func update_attack(attack: int) -> void:
	if attack != initial_attack:
		attack_label.text = ColorConstants.RED_TEXT.format([str(attack)])
	else:
		attack_label.text = str(attack)


func update_cost(cost: int) -> void:
	if cost != initial_cost:
		cost_label.text = ColorConstants.RED_TEXT.format([str(cost)])
	else:
		cost_label.text = str(cost)


func update_labels(card_data: CardData) -> void:
	update_health(card_data.health)
	update_attack(card_data.attack)
	update_cost(card_data.cost)
