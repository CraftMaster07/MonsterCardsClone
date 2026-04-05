class_name AbilityManager
extends Node


const TRIGGER = Ability.TRIGGER


var TRIGGERS_TO_SIGNALS: Dictionary = {
	TRIGGER.ROUND_START: start_turn,
}


@export var board: Board

signal start_turn


func subscribe_card(card: CardData, player: Player):
	var trigger: Ability.TRIGGER = card.get_trigger()

	if is_between(0, trigger, Ability.PLAYER_TRIGGER_THRESHOLD):
		TRIGGERS_TO_SIGNALS[trigger].connect(card.run_ability)
	elif Ability.PLAYER_TRIGGER_THRESHOLD <= trigger:
		player.TRIGGERS_TO_SIGNALS[trigger].connect(card.run_ability)
		# TRIGGERS_TO_SIGNALS[trigger].connect(card.run.bind(player_id))


func board_trigger(trigger):
	TRIGGERS_TO_SIGNALS[trigger].emit()


static func is_between(minimum, n, maximum):
	return minimum < n and n < maximum
	
