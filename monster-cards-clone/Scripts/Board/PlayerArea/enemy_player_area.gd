class_name EnemyPlayerArea
extends PlayerArea


@onready var attack_button: Button = $AttackButton


func get_attack_button() -> Button:
	return attack_button


func disable_area():
	super.disable_area()
	disable_attack_button()


func disable_attack_button():
	attack_button.disabled = true
	attack_button.visible = false
