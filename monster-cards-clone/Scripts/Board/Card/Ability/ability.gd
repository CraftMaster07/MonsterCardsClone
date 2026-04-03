class_name Ability
extends RefCounted


const PLAYER_TRIGGER_THRESHOLD = 50

enum TRIGGER {
    ROUND_START,
    DRAW_CARD = PLAYER_TRIGGER_THRESHOLD,
}


var active_in_hand: bool = false
var trigger: TRIGGER = TRIGGER.ROUND_START
var effect: Effect

func _init(new_trigger: TRIGGER, new_effect: Effect):
    trigger = new_trigger
    effect = new_effect


func run():
    effect.run()


func get_trigger():
    return trigger