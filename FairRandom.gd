extends RefCounted

class_name FairRandom

var fails
var _chance: float
var chance: float:
    set(value):
        _chance = value
        fails = 0

func get_success() -> bool:
    if Utils.geq(fails * _chance, 1):
        fails = 0
        return true
    else:
        var success = _chance > randf()
        if not success:
            fails+=1
        else:
            fails = 0
        return success
