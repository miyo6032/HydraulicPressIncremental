extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

var is_crushed = false
var is_quality:
    get:
        return crush_modifiers.is_quality
var crush_modifiers
var value = 1
var crushable_pattern
var crushable_shape

func update_crush(press_y):
    var resize = (global_position.y - press_y) / sprite.texture.get_height()
    if (resize < 1):
        pass
    scale.y = clamp(resize, 0.0, 1)

func get_current_resistance(progress):
    return crushable_pattern.get_resistance(progress) * crushable_shape.value_multiplier

func calc_crush_progress(press_y):
    var resize = (global_position.y - press_y) / sprite.texture.get_height()
    var progress = clampf(1 - resize, 0.0, 1.0)
    return progress

const slowdown_currency = 0.9
var flat_currency_speedup = 1.2

func get_value():
    if is_crushed:
        if crush_modifiers.is_quality:
            return pow(value, slowdown_currency) * crush_modifiers.value_multiplier * flat_currency_speedup
        else:
            return pow(value, slowdown_currency) * flat_currency_speedup
    return 0

func set_crushed_no_events(modifiers):
    is_crushed = true
    crush_modifiers = modifiers

func set_crushed(modifiers):
    set_crushed_no_events(modifiers)
    if crushable_shape == Constants.reset_trigger_shape and crushable_pattern == Constants.reset_trigger_pattern:
        EventBus.terminal_crush.emit()
    else:
        EventBus.crushable_crushed.emit(self)

func _process(delta):
    if crush_modifiers and crush_modifiers.is_quality:
        var time = Time.get_ticks_msec()
        var lerpValue = (time % 1000) * 0.001
        sprite.modulate = Color.from_hsv(lerpValue, 0.5, 1.0)

func init_no_visuals(shape, pattern):
    crushable_pattern = pattern
    crushable_shape = shape
    value = shape.value_multiplier * pattern.value_multiplier
    crush_modifiers = null

func init(shape, pattern):
    init_no_visuals(shape, pattern)
    sprite.texture = shape.texture
    var material: ShaderMaterial = sprite.material
    material.set_shader_parameter("MainTex", pattern.texture)
