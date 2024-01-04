extends ColorRect

@export var presses: Array[PressRes]
@onready var ui_scene = load("res://press_choice_ui.tscn")
@onready var press_choice_container = %PressChoiceContainer

func _ready():
    Console.add_command("press", func(): visible = true)
    EventBus.terminal_crush.connect(func(): visible = true)
    EventBus.press_selected.connect(func(press_res): visible = false)
    for press in presses:
        var ui = ui_scene.instantiate()
        ui.init(press)
        press_choice_container.add_child(ui)
    visible = false
