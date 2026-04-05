class_name Ability
extends RefCounted


const PLAYER_TRIGGER_THRESHOLD = 50

enum TRIGGER {
    ROUND_START,
    DRAW_CARD = PLAYER_TRIGGER_THRESHOLD,
}


var trigger: TRIGGER
var effect: Effect
var card: CardData
var player: Player

signal activated(effect: Effect, card: CardData, player: Player)

func _init(new_trigger: TRIGGER, new_effect: Effect):
    trigger = new_trigger
    effect = new_effect


func run():
    activated.emit(effect, card, player)


func get_trigger() -> TRIGGER:
    return trigger