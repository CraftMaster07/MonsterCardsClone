class_name AbilityManager
extends Node


const TRIGGER = Ability.TRIGGER


var triggers_to_signals: Dictionary = {
	TRIGGER.ROUND_START: start_turn,
}


@export var board: Board

signal start_turn


func subscribe_card(card: CardData, player: Player):
	var trigger: Ability.TRIGGER = card.get_trigger()

	if is_between(0, trigger, Ability.PLAYER_TRIGGER_THRESHOLD):
		triggers_to_signals[trigger].connect(card.run_ability)
	elif Ability.PLAYER_TRIGGER_THRESHOLD <= trigger:
		player.triggers_to_signals[trigger].connect(card.run_ability)

	card.activated.connect(activate_effect.bind(card, player))


func board_trigger(trigger):
	triggers_to_signals[trigger].emit()


static func is_between(minimum, n, maximum):
	return minimum < n and n < maximum

func activate_effect(effect: Effect, card: CardData, player: Player):
	pass