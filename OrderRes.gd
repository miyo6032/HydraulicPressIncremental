extends Resource

class_name OrderRes

#@export var quality_constraint: String
@export var shape_constraint: CrushableShape
@export var color_constraint: CrushableColor
@export var pattern_constraint: CrushableColor
@export var amount: int
@export var currency: float
@export var id: int

func get_description():
    var desc = "Press %.0f" % amount
    desc += " items"
    return desc
    
func counts_towards_order(crushable):
    return true
