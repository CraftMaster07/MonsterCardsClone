class_name YourCardSlot
extends EnemyCardSlot


@onready var slot_area = $SlotArea
signal clicked(slot)


func take():
	slot_area.process_mode = Node.PROCESS_MODE_DISABLED


func _on_texture_button_pressed() -> void:
	#print("slot clicked")
	clicked.emit(self)


func untake():
	slot_area.process_mode = Node.PROCESS_MODE_INHERIT


func exorcise():
	super.exorcise()
	untake()


func deserialize(serialized_slot: Dictionary):
	super.deserialize(serialized_slot)

	if card:
		take()
	else:
		untake()
