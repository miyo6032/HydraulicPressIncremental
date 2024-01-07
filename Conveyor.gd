extends Node2D

signal move_finished

@export var crushable_scene: PackedScene
@export var crushable_spawn: Node2D
@export var move_offset: Vector2
@onready var shape_list: ShapeList = load("res://data/shape_list.tres")
@onready var pattern_list: PatternList = load("res://data/pattern_list.tres")

var shapes: Array[CrushableShape]:
    get:
        return shape_list.shapes
var patterns: Array[CrushablePattern]:
    get:
        return pattern_list.patterns

var crushables = []

const base_material_level = 3
const crushables_till_press = 2
const base_pattern_level = 1

var material_level = base_material_level
var pattern_level = base_pattern_level

func _ready():
    Console.add_command("mv", move_conveyor)
    EventBus.upgrade_level_changed.connect(upgrade_level_changed)
    
func upgrade_level_changed(instance):
    if instance.upgrade.upgrade_type == Enums.UpgradeType.Materials:
        material_level = base_material_level + instance.current_upgrade_level
        var number_text = Utils.format_whole(material_level)
        var number_label_text = "level"
        instance.set_upgrade_label(number_text, number_label_text)
    if instance.upgrade.upgrade_type == Enums.UpgradeType.MaterialType:
        pattern_level = base_pattern_level + instance.current_upgrade_level
        var number_text = Utils.format_whole(pattern_level + base_pattern_level)
        var number_label_text = "types"
        instance.set_upgrade_label(number_text, number_label_text)  

func move_conveyor():
    var crushable = crushable_scene.instantiate()
    add_child(crushable)
    var shape = shapes[material_level - 3]
    var pattern = patterns[randi_range(0, pattern_level)]
    crushable.init(shape, pattern)
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
        crushable.queue_free()
        
func get_current_crushable():
    return crushables[-crushables_till_press]
    
func has_current_crushable():
    return crushables.size() >= crushables_till_press
    
func save_data(data: Dictionary):
    pass
    
func load_data(data: Dictionary):
    pass
