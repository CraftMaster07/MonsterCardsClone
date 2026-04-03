extends Node


const TRIGGERS = Ability.TRIGGERS


var TRIGGERS_TO_SIGNALS := {
    TRIGGERS.ROUND_START: start_turn,
}


@export var board: Board

signal start_turn


func subscribe_card(card: BoardCard, player: Player):
    var trigger = card.get_trigger()

    if 0 < trigger < Ability.PLAYER_TRIGGER_THRESHOLD:
        TRIGGERS_TO_SIGNALS[trigger].connect(card.run_ability)
    elif Ability.PLAYER_TRIGGER_THRESHOLD <= trigger:
        player.TRIGGERS_TO_SIGNALS[trigger].connect(card.run_ability)
        # TRIGGERS_TO_SIGNALS[trigger].connect(card.run.bind(player_id))
