class_name Ability
extends RefCounted


const PLAYER_TRIGGER_THRESHOLD = 50

enum TRIGGER {
    ROUND_START,
    DRAW_CARD = PLAYER_TRIGGER_THRESHOLD,
}


var trigger: TRIGGER
var effect: Effect

func _init(new_trigger: TRIGGER, new_effect: Effect):
    trigger = new_trigger
    effect = new_effect


func run():
    effect.run()


func get_trigger() -> TRIGGER:
    return trigger