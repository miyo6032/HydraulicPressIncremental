extends Node2D

signal move_finished

@export var crushable_scene: PackedScene
@export var crushable_spawn: Node2D
@export var move_offset: Vector2
@export var pattern: Array[CrushablePattern]
@export var shapes: Array[CrushableShape]

var crushables = []

const base_material_level = 3

var material_level = base_material_level

func _ready():
    Console.add_command("mv", move_conveyor)
    EventBus.upgrade_level_changed.connect(upgrade_level_changed)
    
func upgrade_level_changed(instance):
    if instance.upgrade.upgrade_type == Enums.UpgradeType.Materials:
        material_level = base_material_level + instance.current_upgrade_level
        instance.set_upgrade_label("Max level: %s" % Utils.format_num(material_level))

func move_conveyor():
    var crushable = crushable_scene.instantiate()
    add_child(crushable)
    crushable.init(shapes[randi_range(0, material_level - 3)], pattern[randi_range(0, pattern.size() - 1)])
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
    if crushables.size() > 7:
        var crushable = crushables[0]
        crushables.remove_at(0)
        EventBus.crushable_removed.emit(crushable)
        crushable.queue_free()
        
func get_current_crushable():
    return crushables[-4]
    
func has_current_crushable():
    return crushables.size() > 3
