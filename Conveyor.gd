extends Node2D

signal move_finished

@export var crushable_scene: PackedScene
@export var crushable_spawn: Node2D
@export var move_offset: Vector2
@export var color: CrushableColor
@export var shapes: Array[CrushableShape]

var crushables = []

func _ready():
    Console.add_command("mv", move_conveyor)

func move_conveyor():
    var crushable = crushable_scene.instantiate()
    add_child(crushable)
    crushable.init(shapes[randi_range(0, shapes.size() - 1)], color)
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
        EventBus.crushable_removed.emit(crushable.get_value())
        crushable.queue_free()
        
func get_current_crushable():
    return crushables[-4]
    
func has_current_crushable():
    return crushables.size() > 3
