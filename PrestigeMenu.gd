extends Control

@export var presses: Array[PressRes]
@onready var ui_scene = load("res://press_choice_ui.tscn")
@onready var press_choice_container = %PressChoiceContainer
@onready var fade_ui = $FadePressMenu

var uis = []

func _ready():
    Console.add_command("press", what)
    EventBus.new_press_selected.connect(func(press_res): fade_ui.hide_instantly())
    for press in presses:
        var ui = ui_scene.instantiate()
        ui.init(press)
        press_choice_container.add_child(ui)
        uis.append(ui)
    fade_ui.hide_instantly()

func show_menu(current_run):
    fade_ui.fade_in()
    get_tree().paused = true
    var num_unlocked_presses = current_run.unlocked_presses.size()
    for ui in uis:
        if current_run.unlocked_presses.has(ui.press):
            ui.visible = false
        elif ui.press.minimum_presses_unlocked <= num_unlocked_presses:
            ui.set_available()
        else:
            ui.set_unknown()

func what():
    fade_ui.show_instantly()
