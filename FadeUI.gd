extends Control

class_name FadeUI

const duration = 0.5

var current_tween
var faded_in = false

func _ready():
    hide_instantly()
    mouse_filter = Control.MOUSE_FILTER_IGNORE

func hide_instantly():
    cancel_current_fade()

    modulate.a = 0
    visible = false
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    faded_in = false

func show_instantly():
    cancel_current_fade()

    modulate.a = 1
    visible = true
    mouse_filter = Control.MOUSE_FILTER_STOP
    faded_in = true

func cancel_current_fade():
    if current_tween:
        current_tween.stop()

func fade_in_if_not_active():
    if not faded_in:
        fade_in()

func fade_out_if_not_inactive():
    if faded_in:
        fade_out()

func fade_in():
    cancel_current_fade()
    mouse_filter = Control.MOUSE_FILTER_STOP
    faded_in = true
    current_tween = create_tween()
    visible = true
    current_tween.tween_method(_set_alpha, modulate.a, 1, duration)

func fade_out():
    cancel_current_fade()
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    faded_in = false
    current_tween = create_tween()
    current_tween.tween_method(_set_alpha, modulate.a, 0, duration)
    current_tween.tween_callback(func(): visible = false)

func _set_alpha(value):
    modulate.a = value
