extends Node2D

class_name Press

signal crush_finished

const base_crushing_time: float = 2
const base_max_press_force: float = 1
const base_quality_press_chance: float = 0.0
const base_quality_value_multiplier: float = 5

var max_press_force: float = base_max_press_force
var crushing_time: float = base_crushing_time
var power_hydraulic_multiplier: float = 1
var speed_hydraulic_multiplier: float = 1
var quality_value_multiplier: float = base_quality_value_multiplier

@export var current_press: PressRes
@onready var visual = $Visual
@onready var start_crushing_pos = %PressStart
@onready var final_crushing_pos = %PressEnd
@onready var particles_scene = load("res://crush_particles.tscn")
@onready var press_sprite = $Visual/PressSprite

func _ready():
    visual.global_position = start_crushing_pos.global_position
    EventBus.upgrade_level_changed.connect(upgrade_level_changed)
    EventBus.skip_crushable.connect(skip_crushable)
    EventBus.press_selected.connect(press_selected)
    press_selected(current_press)
    
func press_selected(press_res: PressRes):
    press_sprite.texture = press_res.texture
    current_press = press_res
    
func upgrade_level_changed(instance):
    if instance.upgrade.upgrade_type == Enums.UpgradeType.Force:
        var upgrade_value = pow(instance.upgrade.upgrade_value, instance.current_upgrade_level)
        max_press_force = base_max_press_force * upgrade_value * current_press.force_upgrade
        instance.set_upgrade_label("%s %s" % [Utils.format_num(max_press_force), "ton" if is_equal_approx(max_press_force, 1) else "tons"])
    elif instance.upgrade.upgrade_type == Enums.UpgradeType.PressSpeed:
        var upgrade_value = instance.upgrade.upgrade_value * instance.current_upgrade_level * current_press.speed_upgrade
        crushing_time = base_crushing_time / (1 + upgrade_value)
        instance.set_upgrade_label("%.2f%s Increase" % [(upgrade_value) * 100, "%"])
    elif instance.upgrade.upgrade_type == Enums.UpgradeType.Hydraulics:
        if instance.current_upgrade_level > 0:
            power_hydraulic_multiplier = instance.upgrade.upgrade_value * instance.current_upgrade_level * current_press.hydraulic_force_upgrade
            speed_hydraulic_multiplier =  current_press.hydraulic_speed_downgrade / (instance.upgrade.upgrade_value * instance.current_upgrade_level * 0.5)
        else:
            power_hydraulic_multiplier = current_press.hydraulic_force_upgrade
            speed_hydraulic_multiplier = current_press.hydraulic_speed_downgrade
        instance.set_upgrade_label("%.fx Force, %.2fx Speed" % [power_hydraulic_multiplier, speed_hydraulic_multiplier])
    elif instance.upgrade.upgrade_type == Enums.UpgradeType.Precision:
        var upgrade_value = instance.upgrade.upgrade_value * instance.current_upgrade_level * current_press.precision_upgrade
        quality_random.chance = upgrade_value
        instance.set_upgrade_label("%.0f%s chance" % [(upgrade_value) * 100, "%"])
    elif instance.upgrade.upgrade_type == Enums.UpgradeType.Quality:
        var upgrade_value = base_quality_value_multiplier + instance.upgrade.upgrade_value * instance.current_upgrade_level * current_press.quality_upgrade
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
            if Utils.geq(current_force, max_press_force):
                stop_crush_prematurely(0.5)
            else:
                current_force = clampf(current_force + speed * force_ramp_multiplier * max_press_force, 0, max_press_force)
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

func save_data(data):
    data["current_press"] = current_press
    
func load_data(data):
    press_selected(data["current_press"])
