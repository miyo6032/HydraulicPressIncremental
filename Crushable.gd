extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

var is_crushed = false
var strength = 1

func update_crush(size):
    scale.y = clamp(size / sprite.texture.get_height(), 0.1, 1)

func get_value():
    return 1 if is_crushed else 0

func init(shape, color):
    strength = shape.value_multiplier * color.value_multiplier
    sprite.texture = shape.texture
    sprite.modulate = color.color
