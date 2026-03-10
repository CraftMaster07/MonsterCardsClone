class_name CardFront
extends TextureButton

@export var health_label: RichTextLabel
@export var attack_label: RichTextLabel
@export var cost_label: RichTextLabel

func update_health(health: int) -> void:
	if str(health) != health_label.text:
		health_label.text = ColorConstants.RED_TEXT.format([str(health)])


func update_attack(attack: int) -> void:
	if str(attack) != attack_label.text:
		attack_label.text = ColorConstants.RED_TEXT.format([str(attack)])


func update_cost(cost: int) -> void:
	if str(cost) != cost_label.text:
		cost_label.text = ColorConstants.RED_TEXT.format([str(cost)])


func update_labels(card_data: CardData) -> void:
	update_health(card_data.health)
	update_attack(card_data.attack)
	update_cost(card_data.cost)
