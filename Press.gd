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
var quality_value_multiplier = base_quality_value_multiplier

@onready var visual = $Visual
@onready var start_crushing_pos = %PressStart
@onready var final_crushing_pos = %PressEnd
@onready var particles_scene = load("res://crush_particles.tscn")

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
        quality_random.chance = upgrade_value
        instance.set_upgrade_label("%.0f%s chance" % [(upgrade_value) * 100, "%"])
    elif instance.upgrade.upgrade_type == Enums.UpgradeType.Quality:
        var upgrade_value = base_quality_value_multiplier + instance.upgrade.upgrade_value * instance.current_upgrade_level
        quality_value_multiplier = upgrade_value
        instance.set_upgrade_label("%.0fx value" % [upgrade_value])

func crush(crushable):
    is_crushing = true
    current_force = 0
    particle_buildup = 0
    current_crushable = crushable
        
var current_crushable
var _current_force
var current_force: float:
    get:
        return _current_force
    set(value):
        _current_force = value
        EventBus.current_force_changed.emit(value)
const force_ramp_multiplier = 0.01
const speed_multiplier = 500
var is_crushing
var particle_buildup
        
func _process(delta):
    if not is_crushing:
        return
        
    var time = calc_crushing_time()    
    var speed = speed_multiplier * delta / time
    var crush_progress = current_crushable.calc_crush_progress(visual.global_position.y - speed)
    
    if visual.global_position.y >= final_crushing_pos.global_position.y:
        is_crushing = false
        complete_crush(current_crushable)
        var tween = create_tween()
        tween.tween_callback(func(): current_force = 0).set_delay(time * 0.5)
        tween.tween_property(visual, "global_position", start_crushing_pos.global_position, time)
        tween.tween_callback(func(): crush_finished.emit())        
    if crush_progress > 0:
        var resistance = current_crushable.get_current_resistance(crush_progress)
        if resistance > current_force:
            if current_force >= crushing_power:
                stop_crush_prematurely(0.5)
            else:
                current_force = clampf(current_force + speed * force_ramp_multiplier * crushing_power, 0, crushing_power)
                particle_buildup+=1
        else:
            move_press_down(speed)
            var particles = particles_scene.instantiate()
            if particle_buildup > 1:
                particles.amount = particle_buildup
                particles.emitting = true
                visual.add_child(particles)
                particle_buildup = 0
    else:
        move_press_down(speed)
        
func stop_crush_prematurely(stop_delay):
    is_crushing = false
    var partial_time = 1 - (final_crushing_pos.global_position.y - visual.global_position.y) / (final_crushing_pos.global_position.y - start_crushing_pos.global_position.y)
    var tween = create_tween()
    tween.tween_callback(func(): current_force = 0).set_delay(calc_crushing_time() * stop_delay)                
    tween.tween_property(visual, "global_position", start_crushing_pos.global_position, calc_crushing_time() * partial_time)
    tween.tween_callback(func(): crush_finished.emit())     

func move_press_down(movement):
    visual.global_position.y += movement
    update_crush(current_crushable)

func skip_crushable():
    if is_crushing:
        stop_crush_prematurely(0.25)

@onready var quality_random = FairRandom.new()

func complete_crush(crushable):
    var crush_modifiers = CrushModifiers.new()
    crush_modifiers.is_quality = quality_random.get_success()
    crush_modifiers.value_multiplier = quality_value_multiplier
    crushable.set_crushed(crush_modifiers)
    
func update_crush(crushable):
    crushable.update_crush(visual.global_position.y)
    
func calc_crushing_time():
    return crushing_time / speed_hydraulic_multiplier
