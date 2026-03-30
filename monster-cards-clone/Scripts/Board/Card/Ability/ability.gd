class_name Ability
extends RefCounted


const PLAYER_TRIGGER_THRESHOLD = 50

enum TRIGGERS {
    ROUND_START,
    DRAW_CARD = PLAYER_TRIGGER_THRESHOLD,
}


var trigger = TRIGGERS.ROUND_START
var effect: Effect


func run():
    effect.run()
