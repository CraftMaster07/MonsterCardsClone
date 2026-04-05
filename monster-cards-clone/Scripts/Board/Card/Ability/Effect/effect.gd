class_name Effect
extends RefCounted

enum TARGET {
    SELF,
    FACE
}

var display_name: String
var amount: int
var target: TARGET


func _init(new_amount: int = 1):
    amount = new_amount
