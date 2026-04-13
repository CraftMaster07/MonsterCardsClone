class_name Trigger
extends Resource

const PLAYER_TRIGGER_THRESHOLD = 50

enum TriggerID {
	INVALID = -1,
	ROUND_START,
	DRAW_CARD = PLAYER_TRIGGER_THRESHOLD,
}

enum Null{
	NULL,
}


@export var id: TriggerID = TriggerID.INVALID
@export var display_name: String

@export var effect_blacklist: Dictionary[Effect.EffectID, Null]


func get_id() -> TriggerID:
    return id