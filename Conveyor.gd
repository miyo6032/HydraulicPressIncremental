extends Node2D

@export var crushable_scene: PackedScene
@export var crushable_spawn: Node2D
@export var move_offset: Vector2

var crushables = []

func _ready():
    Console.add_command("mv", move_conveyor)

func move_conveyor():
    var crushable = crushable_scene.instantiate()
    add_child(crushable)
    crushable.global_position = crushable_spawn.global_position
    crushables.append(crushable)
    
    for c in crushables:
        var tween = create_tween()
        tween.tween_property(c, "position", c.position + move_offset, 0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
