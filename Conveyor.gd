extends Node2D

signal move_finished

@export var crushable_scene: PackedScene
@export var crushable_spawn: Node2D
@export var move_offset: Vector2
@export var shapes: Array[CrushableShape]
@export var force_initial_patterns: Array[CrushablePattern]

var crushables = []

const base_material_level = 3
const crushables_till_press = 2

var material_level = base_material_level
var initial_patterns_completed = false
var remaining_patterns

func _ready():
    Console.add_command("mv", move_conveyor)
    EventBus.upgrade_level_changed.connect(upgrade_level_changed)
    remaining_patterns = force_initial_patterns.duplicate()
    
func upgrade_level_changed(instance):
    if instance.upgrade.upgrade_type == Enums.UpgradeType.Materials:
        material_level = base_material_level + instance.current_upgrade_level
        instance.set_upgrade_label("Max level: %s" % Utils.format_num(material_level))

func move_conveyor():
    var crushable = crushable_scene.instantiate()
    add_child(crushable)
    if initial_patterns_completed:
        var shape = shapes[randi_range(0, material_level - 3)]
        crushable.init(shape, shape.possible_patterns[randi_range(0, shape.possible_patterns.size() - 1)])
    else:
        var initial_pattern = remaining_patterns[0]
        crushable.init(shapes[randi_range(0, material_level - 3)], initial_pattern)
        remaining_patterns.remove_at(0)
        if remaining_patterns.size() == 0:
            initial_patterns_completed = true
    crushable.global_position = crushable_spawn.global_position
    crushables.append(crushable)
    
    var animation_time = 0.3
    
    for c in crushables:
        var tween = create_tween()
        tween.tween_property(c, "position", c.position + move_offset, animation_time).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
        
    var tween = create_tween()        
    tween.tween_callback(finish_move).set_delay(animation_time)

func finish_move():
    move_finished.emit()
    if crushables.size() > 3:
        var crushable = crushables[0]
        crushables.remove_at(0)
        EventBus.crushable_removed.emit(crushable)
        crushable.queue_free()
        
func get_current_crushable():
    return crushables[-crushables_till_press]
    
func has_current_crushable():
    return crushables.size() >= crushables_till_press
    
func save_data(data: Dictionary):
    data["initial_patterns_completed"] = initial_patterns_completed
    
func load_data(data: Dictionary):
    initial_patterns_completed = data["initial_patterns_completed"]
    remaining_patterns = force_initial_patterns.duplicate()
