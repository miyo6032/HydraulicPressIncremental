extends Control

@export var presses: Array[PressRes]
@onready var ui_scene = load("res://press_choice_ui.tscn")
@onready var press_choice_container = %PressChoiceContainer
@onready var fade_ui = $FadePressMenu

func _ready():
    Console.add_command("press", what)
    EventBus.terminal_crush.connect(func(): fade_ui.show_instantly())
    EventBus.new_press_selected.connect(func(press_res): fade_ui.hide_instantly())
    for press in presses:
        var ui = ui_scene.instantiate()
        ui.init(press)
        press_choice_container.add_child(ui)
    fade_ui.hide_instantly()

func what():
    fade_ui.show_instantly()
