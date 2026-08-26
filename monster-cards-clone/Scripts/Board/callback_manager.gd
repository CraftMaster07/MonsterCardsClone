class_name CallbackManager
extends Node


var callbacks: Dictionary[String, Callable] = {}


func add_callback(callback: Callable) -> String:
    var callback_uuid = UUID.v4()
    callbacks[callback_uuid] = callback
    return callback_uuid


func pop_callback(callback_uuid: String) -> Callable:
    var callback = callbacks[callback_uuid]
    callbacks.erase(callback_uuid)
    return callback
