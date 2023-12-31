extends Node2D

@export var crushing_time: float
@onready var visual = $Visual
@onready var start_crushing_pos = $PressStart
@onready var final_crushing_pos = $PressStart/PressEnd

func _ready():
    visual.global_position = start_crushing_pos.global_position

func crush(crushable):
    var tween = create_tween()
    tween.tween_property(visual, "global_position", final_crushing_pos.global_position, 2.0)
    tween.tween_property(visual, "global_position", start_crushing_pos.global_position, 2.0).set_delay(1.0)
