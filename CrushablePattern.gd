extends Resource

class_name CrushablePattern

@export var value_multiplier: float
@export var texture: Texture2D
@export var curve: Curve

func get_resistance(progress: float):
    return curve.sample(progress) * value_multiplier
