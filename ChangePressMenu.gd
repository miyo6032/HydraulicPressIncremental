extends ColorRect

@onready var change_press_ui = load("res://change_press_ui.tscn")
@onready var container = %ChangePressContainer

func _ready():
    visible = false

func load(presses):
    visible = true
    for n in container.get_children():
        container.remove_child(n)
        n.queue_free()
    for press in presses:
        var press_ui = change_press_ui.instantiate()
        press_ui.init(press)
        container.add_child(press_ui)
        press_ui.chosen.connect(press_ui_chosen)
        
func press_ui_chosen(press_res):
    visible = false
    EventBus.press_selected.emit(press_res)
