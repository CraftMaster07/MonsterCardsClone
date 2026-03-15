class_name CardFront
extends TextureButton

@export var health_label: RichTextLabel
@export var attack_label: RichTextLabel
@export var cost_label: RichTextLabel

var initial_health: int = -1
var initial_attack: int = -1
var initial_cost: int = -1


func set_initial_values(card_data: CardData) -> void:
	initial_health = card_data.health
	initial_attack = card_data.attack
	initial_cost = card_data.cost
	update_labels(card_data)


func update_health(health: int) -> void:
	if health != initial_health:
		health_label.text = ColorConstants.RED_TEXT.format([str(health)])


func update_attack(attack: int) -> void:
	if attack != initial_attack:
		attack_label.text = ColorConstants.RED_TEXT.format([str(attack)])


func update_cost(cost: int) -> void:
	if cost != initial_cost:
		cost_label.text = ColorConstants.RED_TEXT.format([str(cost)])


func update_labels(card_data: CardData) -> void:
	update_health(card_data.health)
	update_attack(card_data.attack)
	update_cost(card_data.cost)
