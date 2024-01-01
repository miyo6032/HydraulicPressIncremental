extends Node2D

class_name Press

signal crush_finished

const base_crushing_time = 2
const base_crushing_power = 1
const base_quality_press_chance = 0.0
const base_quality_value_multiplier = 5

var crushing_power = base_crushing_power
var crushing_time = base_crushing_time
var power_hydraulic_multiplier = 1
var speed_hydraulic_multiplier = 1
var quality_press_chance = base_quality_press_chance
var quality_value_multiplier = base_quality_value_multiplier

@onready var visual = $Visual
@onready var start_crushing_pos = $PressStart
@onready var final_crushing_pos = $PressStart/PressEnd

func _ready():
    visual.global_position = start_crushing_pos.global_position
    EventBus.upgrade_level_changed.connect(upgrade_level_changed)
    EventBus.skip_crushable.connect(skip_crushable)
    
func upgrade_level_changed(instance):
    if instance.upgrade.upgrade_type == Enums.UpgradeType.Force:
        var upgrade_value = pow(instance.upgrade.upgrade_value, instance.current_upgrade_level)
        crushing_power = base_crushing_power * upgrade_value
        instance.set_upgrade_label("%s ton" % Utils.format_num(upgrade_value))
    elif instance.upgrade.upgrade_type == Enums.UpgradeType.PressSpeed:
        var upgrade_value = instance.upgrade.upgrade_value * instance.current_upgrade_level
        crushing_time = base_crushing_time / (1 + upgrade_value)
        instance.set_upgrade_label("%.2f%s Increase" % [(upgrade_value) * 100, "%"])
    elif instance.upgrade.upgrade_type == Enums.UpgradeType.Hydraulics:
        if instance.current_upgrade_level > 0:
            power_hydraulic_multiplier = instance.upgrade.upgrade_value * instance.current_upgrade_level
            speed_hydraulic_multiplier = 1 / (instance.upgrade.upgrade_value * instance.current_upgrade_level * 0.5)
        else:
            power_hydraulic_multiplier = 1
            speed_hydraulic_multiplier = 1
        instance.set_upgrade_label("%.fx Force, %.2fx Speed" % [power_hydraulic_multiplier, speed_hydraulic_multiplier])
    elif instance.upgrade.upgrade_type == Enums.UpgradeType.Precision:
        var upgrade_value = instance.upgrade.upgrade_value * instance.current_upgrade_level
        quality_press_chance = upgrade_value
        instance.set_upgrade_label("%.0f%s chance" % [(upgrade_value) * 100, "%"])
    elif instance.upgrade.upgrade_type == Enums.UpgradeType.Quality:
        var upgrade_value = base_quality_value_multiplier + instance.upgrade.upgrade_value * instance.current_upgrade_level
        quality_value_multiplier = upgrade_value
        instance.set_upgrade_label("%.0fx value" % [upgrade_value])

var crush_tween
var current_crushable

func crush(crushable):
    var failed_crush = crushable.strength > crushing_power * power_hydraulic_multiplier
    var time = calc_crushing_time()
    current_crushable = crushable
    if failed_crush:
        var tween = create_tween()
        var partial_position = (final_crushing_pos.global_position - start_crushing_pos.global_position) * 0.65 + start_crushing_pos.global_position
        tween.tween_method(update_crush.bind(crushable), start_crushing_pos.global_position, partial_position, time)
        tween.tween_method(update_crush.bind(crushable), partial_position, start_crushing_pos.global_position, time)
        tween.tween_callback(func(): crush_finished.emit())
        crush_tween = tween
    else:
        var tween = create_tween()
        tween.tween_method(update_crush.bind(crushable), start_crushing_pos.global_position, final_crushing_pos.global_position, time)
        tween.tween_property(visual, "global_position", start_crushing_pos.global_position, time).set_delay(time * 0.5)
        tween.tween_callback(complete_crush.bind(crushable))
        crush_tween = tween

func skip_crushable():
    if crush_tween:
        crush_tween.kill()
        update_crush(start_crushing_pos.global_position, current_crushable)
        crush_finished.emit()
        crush_tween = null

func complete_crush(crushable):
    var crush_modifiers = CrushModifiers.new()
    crush_modifiers.is_quality = quality_press_chance > randf_range(0, 1.0)
    crush_modifiers.value_multiplier = quality_value_multiplier
    crushable.set_crushed(crush_modifiers)
    crush_finished.emit()
    
func update_crush(pos, crushable):
    visual.global_position = pos    
    crushable.update_crush(final_crushing_pos.global_position.y - visual.global_position.y)
    
func calc_crushing_time():
    return crushing_time / speed_hydraulic_multiplier
