extends Node2D

var selected_card : Card
@onready var hand := $Hand

@onready var select_stream : AudioStream = load("res://assets/audio/sounds/select.mp3")
@onready var deselect_stream : AudioStream = load("res://assets/audio/sounds/deselect.mp3")

func _ready() -> void:
	for card in hand.get_children():
		card.connect("card_selected", select_card)

func _process(delta: float) -> void:
	print(selected_card)

func select_card(card):
	if selected_card == card:
		selected_card = null
		play_sound_at_card(card, deselect_stream)
	else:
		selected_card = card
		play_sound_at_card(card, select_stream)
		

func play_sound_at_card(card: Card, sound: AudioStream) -> void:
	var sound_player = AudioStreamPlayer2D.new()
	sound_player.bus = "SFX"
	card.add_child(sound_player)
	sound_player.position = card.position
	sound_player.stream = sound
	sound_player.play()
	sound_player.connect("finished", sound_player.queue_free)
		
