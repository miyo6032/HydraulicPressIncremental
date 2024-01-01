extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

var is_crushed = false
var crush_modifiers
var value = 1
var crushable_pattern
var crushable_shape

func update_crush(size):
    scale.y = clamp(size / sprite.texture.get_height(), 0.1, 1)
    
func get_current_resistance(progress):
    return crushable_pattern.get_resistance(progress) * crushable_shape.value_multiplier
    
func calc_crush_progress(distance_from_bottom):
    return 1 - clamp(distance_from_bottom / sprite.texture.get_height(), 0.0, 1)

func get_value():
    if is_crushed:
        if crush_modifiers.is_quality:
            return value * crush_modifiers.value_multiplier
        else:
            return value
    return 0

func set_crushed(modifiers):
    is_crushed = true
    crush_modifiers = modifiers
    
func _process(delta):
    if crush_modifiers and crush_modifiers.is_quality:
        var time = Time.get_ticks_msec()
        var lerpValue = (time % 1000) * 0.001
        sprite.modulate = Color.from_hsv(lerpValue, 0.5, 1.0)

func init(shape, pattern):
    crushable_pattern = pattern
    crushable_shape = shape
    value = shape.value_multiplier * pattern.value_multiplier
    sprite.texture = shape.texture
    var material: ShaderMaterial = sprite.material
    material.set_shader_parameter("MainTex", pattern.texture)
    #sprite.modulate = color.color
    crush_modifiers = null
