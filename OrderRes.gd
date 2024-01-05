extends Resource

class_name OrderRes

@export var shape_constraint: CrushableShape
@export var pattern_constraint: CrushablePattern
@export var amount: int
@export var currency: float
@export var id: int

func get_description():
    var desc = "Press %.0f" % amount
    desc += " items"
    return desc
    
func counts_towards_order(crushable):
    return true
