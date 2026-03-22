extends RefCounted
class_name CardFile

const SAVE_PATH: String = "user://Cards/"

var card_name: String = ""
var health: int = 0
var attack: int = 0
var cost: int = 0


func save():
    if not DirAccess.dir_exists_absolute(SAVE_PATH):
        DirAccess.make_dir_absolute(SAVE_PATH)
    
    var file_name := card_name.replace(" ", "_")
    var file := FileAccess.open(SAVE_PATH + file_name + ".json", FileAccess.WRITE)
    var data := {
        "card_name": card_name,
        "health": health,
        "attack": attack,
        "cost": cost
    }
    var stringified_data := JSON.stringify(data)
    file.store_string(stringified_data)
    file.close()