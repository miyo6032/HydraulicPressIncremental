extends Node2D

signal crush_finished

const crushing_time = 0.5
const base_crushing_power = 1

var crushing_power = 1

@onready var visual = $Visual
@onready var start_crushing_pos = $PressStart
@onready var final_crushing_pos = $PressStart/PressEnd

func _ready():
    visual.global_position = start_crushing_pos.global_position
    EventBus.upgrade_level_changed.connect(upgrade_level_changed)
    
func upgrade_level_changed(instance):
    if instance.upgrade.upgrade_type == Enums.UpgradeType.Force:
        var upgrade_value = pow(instance.upgrade.upgrade_value, instance.upgrade_level)
        crushing_power = base_crushing_power * upgrade_value
        instance.set_upgrade_label("%s kg" % Utils.format_num(upgrade_value))

func crush(crushable):
    var failed_crush = crushable.strength > crushing_power
    if failed_crush:
        var tween = create_tween()
        var partial_position = (final_crushing_pos.global_position - start_crushing_pos.global_position) * 0.5 + start_crushing_pos.global_position
        tween.tween_method(update_crush.bind(crushable), start_crushing_pos.global_position, partial_position, crushing_time)
        tween.tween_method(update_crush.bind(crushable), partial_position, start_crushing_pos.global_position, crushing_time)
        tween.tween_callback(func(): crush_finished.emit())
    else:
        var tween = create_tween()
        tween.tween_method(update_crush.bind(crushable), start_crushing_pos.global_position, final_crushing_pos.global_position, crushing_time)
        tween.tween_property(visual, "global_position", start_crushing_pos.global_position, crushing_time).set_delay(crushing_time * 0.5)
        tween.tween_callback(complete_crush.bind(crushable))

func complete_crush(crushable):
    crushable.is_crushed = true
    crush_finished.emit()
    
func update_crush(pos, crushable):
    visual.global_position = pos    
    crushable.update_crush(final_crushing_pos.global_position.y - visual.global_position.y)
