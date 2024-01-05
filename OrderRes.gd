extends Resource

class_name OrderRes

@export var shape_constraint: CrushableShape
@export var pattern_constraint: CrushablePattern
@export var amount: int
@export var currency: float
var id: 
    get:
        return resource_path

func get_description():
    var desc = "Press %.0f" % amount
    desc += " items"
    return desc

func counts_towards_order(crushable):
    if shape_constraint:
        if pattern_constraint:
            return crushable.crushable_pattern == pattern_constraint and crushable.crushable_shape == shape_constraint
        else:
            return crushable.crushable_shape == shape_constraint
    else:
        return true
