extends Label

@onready var sfx_wrong: AudioStreamPlayer = $SfxWrong

func activate(error_text: String):
	text = error_text
	visible = true
	sfx_wrong.play()


func deactivate():
	visible = false
	
