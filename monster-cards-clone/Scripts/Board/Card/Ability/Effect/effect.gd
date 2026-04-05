class_name Effect
extends RefCounted

var display_name: String
var amount: int


func _init(new_amount: int = 1):
    amount = new_amount


func run():
    push_error("not implemented")
