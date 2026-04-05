class_name Heal
extends Effect


signal healed(amount: int)


func run():
	healed.emit(amount)
	print("healed ", amount)
