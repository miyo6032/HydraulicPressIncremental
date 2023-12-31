extends Node2D

signal crush_finished

@export var crushing_time: float
@onready var visual = $Visual
@onready var start_crushing_pos = $PressStart
@onready var final_crushing_pos = $PressStart/PressEnd

func _ready():
    visual.global_position = start_crushing_pos.global_position

func crush(crushable):
    var tween = create_tween()
    tween.tween_method(update_crush.bind(crushable), start_crushing_pos.global_position, final_crushing_pos.global_position, 2.0)
    tween.tween_property(visual, "global_position", start_crushing_pos.global_position, 2.0).set_delay(1.0)
    tween.tween_callback(func(): crush_finished.emit())

func update_crush(pos, crushable):
    visual.global_position = pos    
    crushable.update_crush(final_crushing_pos.global_position.y - visual.global_position.y)
