extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

var is_crushed = false
var crush_modifiers
var strength = 1

func update_crush(size):
    scale.y = clamp(size / sprite.texture.get_height(), 0.1, 1)

func get_value():
    if is_crushed:
        if crush_modifiers.is_quality:
            return strength * crush_modifiers.value_multiplier
        else:
            return strength
    return 0

func set_crushed(modifiers):
    is_crushed = true
    crush_modifiers = modifiers
    
func _process(delta):
    if crush_modifiers and crush_modifiers.is_quality:
        var time = Time.get_ticks_msec()
        var lerpValue = (time % 1000) * 0.001
        sprite.modulate = Color.from_hsv(lerpValue, 0.5, 1.0)

func init(shape, color):
    strength = shape.value_multiplier * color.value_multiplier
    sprite.texture = shape.texture
    sprite.modulate = color.color
    crush_modifiers = null
