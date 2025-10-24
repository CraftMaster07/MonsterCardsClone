extends Node


var peer = ENetMultiplayerPeer.new()


func _on_host_button_pressed() -> void:
    disable_buttons()


func disable_buttons() -> void:
    $HostButton.disabled = true
    $JoinButton.disabled = true
