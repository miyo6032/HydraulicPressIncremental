extends Node2D

class_name Press

signal crush_finished

const base_crushing_time: float = 2.5
const base_max_press_force: float = 2
const base_quality_press_chance: float = 0.0
const base_quality_value_multiplier: float = 5

var max_press_force: float = base_max_press_force
var crushing_time: float = base_crushing_time
var power_hydraulic_multiplier: float = 1
var speed_hydraulic_multiplier: float = 1
var quality_value_multiplier: float = base_quality_value_multiplier
var final_max_press_force: float:
    get:
        return max_press_force * power_hydraulic_multiplier

@export var current_press: PressRes
@export var crushed_particles: PackedScene
@onready var visual = $Visual
@onready var start_crushing_pos = %PressStart
@onready var final_crushing_pos = %PressEnd
@onready var particles_scene
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
    particles_scene = current_press.press_particles
    
func upgrade_level_changed(instance):
    if instance.upgrade.upgrade_type == Enums.UpgradeType.Force:
        var calc_upgrade_value = func(upgrade_level): return pow(instance.upgrade.upgrade_value, upgrade_level)
        var calc_press_force = func(value): return base_max_press_force * value * current_press.force_upgrade
        var upgrade_value = calc_upgrade_value.call(instance.current_upgrade_level)

        max_press_force = calc_press_force.call(upgrade_value)
        var number_text = Utils.format_num(max_press_force)
        var number_label_text = "ton" if is_equal_approx(max_press_force, 1) else "tons"
        
        if instance.max_upgrade_level < instance.upgrade.max_level:
            var next_upgrade_value = calc_upgrade_value.call(instance.current_upgrade_level + 1)
            var next_max_press_force = calc_press_force.call(next_upgrade_value)     
            var next_upgrade_label = "next level: %s %s" % [Utils.format_num(next_max_press_force), "ton" if is_equal_approx(next_max_press_force, 1) else "tons"]
            instance.set_upgrade_label(number_text, number_label_text, next_upgrade_label)
        else:
            instance.set_upgrade_label(number_text, number_label_text)
            
    elif instance.upgrade.upgrade_type == Enums.UpgradeType.PressSpeed:
        var upgrade_value = instance.upgrade.upgrade_value * instance.current_upgrade_level + current_press.speed_upgrade
        crushing_time = base_crushing_time / (1 + upgrade_value)
        var number_text = Utils.format_whole(upgrade_value * 100) + "%"
        var number_label_text = "increase"
        instance.set_upgrade_label(number_text, number_label_text)        
    elif instance.upgrade.upgrade_type == Enums.UpgradeType.Hydraulics:
        if instance.current_upgrade_level > 0:
            power_hydraulic_multiplier = instance.upgrade.upgrade_value * instance.current_upgrade_level * current_press.hydraulic_force_upgrade
            speed_hydraulic_multiplier =  current_press.hydraulic_speed_downgrade / (instance.upgrade.upgrade_value * instance.current_upgrade_level * 0.5)
        else:
            power_hydraulic_multiplier = current_press.hydraulic_force_upgrade
            speed_hydraulic_multiplier = current_press.hydraulic_speed_downgrade
        var number_text = "%sx > %sx" % [Utils.round_to_dec(speed_hydraulic_multiplier, 3), Utils.format_whole(power_hydraulic_multiplier)]
        var number_label_text = "speed for force"
        instance.set_upgrade_label(number_text, number_label_text)    
    elif instance.upgrade.upgrade_type == Enums.UpgradeType.Precision:
        var upgrade_value = instance.upgrade.upgrade_value * instance.current_upgrade_level + current_press.precision_upgrade
        quality_random.chance = upgrade_value
        var number_text = Utils.format_whole(upgrade_value * 100) + "%"
        var number_label_text = "chance"
        instance.set_upgrade_label(number_text, number_label_text)    
    elif instance.upgrade.upgrade_type == Enums.UpgradeType.Quality:
        var upgrade_value = base_quality_value_multiplier + instance.upgrade.upgrade_value * instance.current_upgrade_level + current_press.quality_upgrade
        quality_value_multiplier = upgrade_value
        var number_text = "%.0fx" % upgrade_value
        var number_label_text = "bonus $"
        instance.set_upgrade_label(number_text, number_label_text)    

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
        EventBus.current_force_changed.emit(value, max_press_force)
const force_ramp_multiplier = 0.01
const speed_multiplier = 500
var is_crushing
var particle_buildup
        
func _physics_process(delta):
    if not is_crushing:
        return
        
    var time = calc_crushing_time()    
    var speed = speed_multiplier * delta / time
    var crush_progress = current_crushable.calc_crush_progress(visual.global_position.y - speed)
    
    if visual.global_position.y >= final_crushing_pos.global_position.y:
        is_crushing = false
        complete_crush(current_crushable)
        var tween = create_tween()
        tween.tween_callback(func(): current_force = 0).set_delay(clamp(time * 0.5, 0, 1))
        tween.tween_property(visual, "global_position", start_crushing_pos.global_position, time)
        tween.tween_callback(func(): crush_finished.emit())
    elif crush_progress > 0:
        var resistance = current_crushable.get_current_resistance(crush_progress)
        if resistance > current_force:
            if Utils.geq(current_force, final_max_press_force):
                stop_crush_prematurely(0.5)
            else:
                current_force = clampf(current_force + speed * force_ramp_multiplier * final_max_press_force, 0, final_max_press_force)
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
    EventBus.crushable_crushed.emit(current_crushable)

func move_press_down(movement):
    visual.global_position.y = clamp(visual.global_position.y + movement, start_crushing_pos.global_position.y, final_crushing_pos.global_position.y)
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
    var particles = crushed_particles.instantiate()
    add_child(particles)
    particles.global_position = final_crushing_pos.global_position
    particles.emitting = true
    
func update_crush(crushable):
    crushable.update_crush(visual.global_position.y)
    
func calc_crushing_time():
    return crushing_time / speed_hydraulic_multiplier

func save_data(data):
    data["current_press"] = current_press.id
    
func load_data(data):
    press_selected(Registries.press_types[data["current_press"]])
